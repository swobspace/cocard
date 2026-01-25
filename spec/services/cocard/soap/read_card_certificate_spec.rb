require 'rails_helper'

module Cocard::SOAP
  RSpec.describe ReadCardCertificate do
    let(:yaml) do
      File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector_services.yaml')
    end
    let(:connector) do
      FactoryBot.create(:connector,
        ip: ENV['SDS_IP'],
        use_tls: ENV['USE_TLS'] || false,
        authentication: ENV['AUTHENTICATION'] || 'noauth',
        auth_user: ENV['AUTH_USER'],
        auth_password: ENV['AUTH_PASSWORD'],
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
      Cocard::SOAP::ReadCardCertificate.new(
        connector: connector,
        mandant: ENV['CONN_MANDANT'],
        client_system: ENV['CONN_CLIENT_SYSTEM_ID'],
        workplace: ENV['CONN_WORKPLACE_ID'],
        card_handle: ENV['CARD_HANDLE'],
        cert_ref_list: %w( C.AUT C.ENC ),
        crypt: 'ECC',
        user_id: 'cocard'
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
          Cocard::SOAP::ReadCardCertificate.new(
            connector: connector,
            mandant: 'dontexist',
            client_system: 'dontexist',
            workplace: 'dontexist',
            card_handle: 'c9decf82-ee3d-11f0-b35f-c025a5b36994'
          ).call
        end
        it { expect(result.success?).to be_falsey }
        if ENV['USE_TLS'] && ENV['AUTHENTICATION'] == 'clientcert'
          # it { puts result.error_messages.inspect }
          it { expect(result.error_messages.join(",")).to match(/Clientsystem aus dem Aufrufkontext konnte nicht authentifiziert werden/) }
        elsif ENV['AUTHENTICATION'] == 'basicauth'
          it { expect(result.error_messages).to contain_exactly(
               "Clientsystem aus dem Aufrufkontext konnte nicht authentifiziert werden.",
               "S:Server", "code: 4204") }
        else
          it { expect(result.error_messages).to contain_exactly(
                 "S:Server", "Karten-Handle ungültig")}
        end

      end

      describe "successful call" do
        let(:result) { subject.call }

        it { puts subject.soap_message }

        it { pp  result.response }
        it { expect(result.success?).to be_truthy }
        it { expect(result.response.keys).to contain_exactly(:read_card_certificate_response) }
      end
    end
  end
end
