require 'rails_helper'

module Cocard::SOAP
  RSpec.describe GetResourceInformation do
    let(:yaml) do
      File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector_services.yaml')
    end
    let(:connector) do
      FactoryBot.create(:connector,
        ip: ENV['SDS_IP'],
        use_tls: ENV['USE_TLS'] || false,
        authentication: ENV['AUTHENTICATION'] || 'noauth',
        connector_services: YAML.load_file(yaml)
      )
    end

    let(:clientcert) do
      FactoryBot.create(:client_certificate,
        name: 'myname',
        cert: File.read(ENV['CLIENT_CERT_FILE']),
        pkey: File.read(ENV['CLIENT_PKEY_FILE']),
        passphrase: ENV['CLIENT_CERT_PASSPHRASE']
      )
    end

    subject do
      Cocard::SOAP::GetResourceInformation.new(
        connector: connector,
        mandant: ENV['CONN_MANDANT'],
        client_system: ENV['CONN_CLIENT_SYSTEM_ID'],
        workplace: ENV['CONN_WORKPLACE_ID']
      )
    end
    before(:each) do
      connector.client_certificates << clientcert
      connector.reload
    end

    it "does not raise an NotImplementedError" do
      expect { subject }.not_to raise_error
    end

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject.respond_to?(:call)).to be_truthy }
    end

    # must be explicit called with rspec --tag soap
    describe '#call', :soap => true do
      describe "return error if not successful" do
        let(:result) do
          Cocard::SOAP::GetResourceInformation.new(
            connector: connector,
            mandant: 'dontexist',
            client_system: 'dontexist',
            workplace: 'dontexist'
          ).call
        end
        it { puts connector.use_tls }
        it { puts connector.client_certificates.first }
        it { expect(result.success?).to be_falsey }
        if ENV['USE_TLS']
          it { expect(result.error_messages.first).to match(/Missing matching client certificate for client_system: dontexist/) }
        else
          it { expect(result.error_messages).to contain_exactly(
                 "S:Server", "Ungültige Mandanten-ID")}
        end
      end

      describe "successful call" do
        let(:result) { subject.call }
        it { pp  result.response }

        it { expect(result.success?).to be_truthy }
        it { expect(result.response.keys).to contain_exactly(:get_resource_information_response) }
      end
    end
  end
end
