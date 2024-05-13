require 'rails_helper'

module Cocard::SOAP
  RSpec.describe ReadCardCertificate do
    let(:yaml) do
      File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector_services.yaml')
    end
    let(:connector) do
      FactoryBot.create(:connector,
        ip: ENV['SDS_IP'],
        connector_services: YAML.load_file(yaml)
      )
    end

    subject do
      Cocard::SOAP::ReadCardCertificate.new(
        connector: connector,
        mandant: ENV['CONN_MANDANT'],
        client_system: ENV['CONN_CLIENT_SYSTEM_ID'],
        workplace: ENV['CONN_WORKPLACE_ID'],
        card_handle: ENV['CARD_HANDLE']
      )
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
            card_handle: 'dontexist'
          ).call
        end
        it { expect(result.success?).to be_falsey }
        it { expect(result.error_messages).to contain_exactly(
               "S:Server", "Karten-Handle ungültig")}
      end

      describe "successful call" do
        let(:result) { subject.call }
        it { pp  result.response }

        it { expect(result.success?).to be_truthy }
        it { expect(result.response.keys).to contain_exactly(:read_card_certificate_response) }
      end
    end
  end
end
