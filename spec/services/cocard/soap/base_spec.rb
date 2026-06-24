require 'rails_helper'

module Cocard::SOAP
  RSpec.describe Base do
    let(:connector) do
      FactoryBot.create(:connector,
        ip: ENV['SDS_IP'],
      )
    end

    it "raise an NotImplementedError" do
      expect {
        Cocard::SOAP::Base.new(
          connector: connector,
          mandant: 'Ein1',
          client_system: 'Cocard',
          workplace: 'Konnektor'
        )
      }.to raise_error NotImplementedError
    end

    it "preserves string-keyed SOAP fault trace code and detail in error messages" do
      savon_client = double('savon_client')
      soap_fault = Savon::SOAPFault.allocate
      allow(soap_fault).to receive(:to_hash).and_return(
        'fault' => {
          'faultcode' => 'soap:Server',
          'faultstring' => 'Connector error',
          'detail' => {
            'error' => {
              'trace' => {
                'code' => '4060',
                'detail' => 'Ressource belegt'
              }
            }
          }
        }
      )
      allow(savon_client).to receive(:call).and_raise(soap_fault)

      soap_class = Class.new(Cocard::SOAP::Base) do
        def soap_operation
          :verify_pin
        end

        def init_savon_client
          options.fetch(:savon_client)
        end

        def check_auth
          true
        end
      end

      result = soap_class.new(
        connector: double('connector', connector_services: [double('connector_service')]),
        mandant: 'Ein1',
        client_system: 'Cocard',
        workplace: 'Konnektor',
        savon_client: savon_client
      ).call

      expect(result).not_to be_success
      expect(result.error_messages.join(' ')).to include('4060')
      expect(result.error_messages.join(' ')).to include('Ressource belegt')
    end
  end
end
