module Cocard::SOAP
  class VerifyPin < Base
    def soap_operation
      :verify_pin
    end

    def fetch_specific_options(options)
      @mandant       = options.fetch(:mandant)
      @client_system = options.fetch(:client_system)
      @workplace     = options.fetch(:workplace)
      @card_handle   = options.fetch(:card_handle)
      @pin_typ       = options.fetch(:pin_typ) { 'PIN.SMC' }
    end

    def soap_message
      { 
        "CCTX:Context" => {
          "CONN:MandantId"      => @mandant,
          "CONN:ClientSystemId" => @client_system,
          "CONN:WorkplaceId"    => @workplace  },
          "CONN:CardHandle" => @card_handle,
          "CARDCMN:PinTyp" => @pin_typ
      }
    end

    def wsdl_content
      content = File.join(Rails.root, 'shared', 'wdsl', "CardService.wsdl")
    end

    def endpoint_location
      # "http://#{connector_ip}/service/certificateservice"
      return nil unless @connector.kind_of? Connector
      @connector.service("CardService")&.endpoint_location(Cocard::CardServiceVersion)
    end

    def endpoint_tls_location
      # "http://#{connector_ip}/service/certificateservice"
      return nil unless @connector.kind_of? Connector
      @connector.service("CardService")&.endpoint_tls_location(Cocard::CardServiceVersion)
    end

    def namespace
      return nil unless @connector.kind_of? Connector
      # 'http://ws.gematik.de/conn/CardService/v8.1.2'
      # sorry, wild hack for Gematik namespace troubles, savon couldn't handle it
      @connector.service("CardService")
                &.target_namespace(Cocard::CardServiceVersion)
                &.gsub(/WSDL\//, '')
    end

  end
end
