module Cocard::SOAP
  class CheckCertificateExpiration < Base
    def soap_operation
      :check_certificate_expiration
    end

    def fetch_specific_options(options)
      @mandant       = options.fetch(:mandant)
      @client_system = options.fetch(:client_system)
      @workplace     = options.fetch(:workplace)
    end

    def soap_message
      { 
        "CCTX:Context" => {
          "CONN:MandantId"      => @mandant,
          "CONN:ClientSystemId" => @client_system,
          "CONN:WorkplaceId"    => @workplace  }
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
