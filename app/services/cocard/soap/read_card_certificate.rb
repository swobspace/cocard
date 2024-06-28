module Cocard::SOAP
  class ReadCardCertificate < Base
    def soap_operation
      :read_card_certificate
    end

    def fetch_specific_options(options)
      @mandant       = options.fetch(:mandant)
      @client_system = options.fetch(:client_system)
      @workplace     = options.fetch(:workplace)
      @card_handle   = options.fetch(:card_handle)
    end

    def soap_message
      { 
        "CONN:CardHandle" => @card_handle,
        "CCTX:Context" => {
          "CONN:MandantId"      => @mandant,
          "CONN:ClientSystemId" => @client_system,
          "CONN:WorkplaceId"    => @workplace  },
        "CERT:CertRefList" => {
          "CERT:CertRef" => 'C.ENC'
        }
      }
    end

    def wsdl_content
      content = File.join(Rails.root, 'shared', 'wdsl', "CertificateService.wsdl")
    end

    def endpoint_location
      # "http://#{connector_ip}/service/certificateservice"
      return nil unless @connector.kind_of? Connector
      @connector.service("CertificateService")&.endpoint_location(Cocard::CertificateServiceVersion)
    end

    def endpoint_tls_location
      # "http://#{connector_ip}/service/certificateservice"
      return nil unless @connector.kind_of? Connector
      @connector.service("CertificateService")&.endpoint_tls_location(Cocard::CertificateServiceVersion)
    end

    def namespace
      return nil unless @connector.kind_of? Connector
      # 'http://ws.gematik.de/conn/CertificateService/v6.0'
      # sorry, wild hack for Gematik namespace troubles, savon couldn't handle it
      @connector.service("CertificateService")
                &.target_namespace(Cocard::CertificateServiceVersion)
                &.gsub(/WSDL\//, '')
    end
  end
end
