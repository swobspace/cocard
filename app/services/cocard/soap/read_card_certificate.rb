module Cocard::SOAP
  #
  # Base class to be inherited by operation specific classes
  #
  class ReadCardCertificate
    Result = ImmutableStruct.new(:success?, :error_messages, :response)

    # service = Cocard::SOAP::ReadCardCertificate.new(options)
    #
    # mandantory options:
    # * :connector - object
    # * :mandant - string
    # * :client_system - string
    # * :workplace - string
    # * :card_handle - string
    #
    # returns:
    # Result.new(:success? (Boolean), :error_messages (Array), :response (Hash))
    #
    def initialize(options = {})
      options.symbolize_keys
      @connector     = options.fetch(:connector)
      @mandant       = options.fetch(:mandant)
      @client_system = options.fetch(:client_system)
      @workplace     = options.fetch(:workplace)
      @card_handle   = options.fetch(:card_handle)
      @savon_client  = init_savon_client
    end

    # service.call()
    # do all the work here ;-)
    def call
      error_messages = []
      begin
        response = @savon_client
                   .call(:read_card_certificate,
                         message: {
                           "CONN:CardHandle" => @card_handle,
                           "CCTX:Context" => {
                             "CONN:MandantId"      => @mandant,
                             "CONN:ClientSystemId" => @client_system,
                             "CONN:WorkplaceId"    => @workplace  },
                           "CERT:CertRefList" => {
                             "CERT:CertRef" => 'C.ENC'
                           }
                       })
      rescue Savon::Error => error
        fault = error.to_hash[:fault]
        error_messages = [fault[:faultcode], fault[:faultstring]]
        return Result.new(success?: false, error_messages: error_messages, response: nil)
      end

      Result.new(success?: true, error_messages: error_messages, response: response.body)
    end

  private
    def init_savon_client
      client = Savon.client(
           wsdl: wsdl_content,
           endpoint: endpoint,
           env_namespace: :soapenv,
           namespace: namespace,
           namespaces: namespaces,
           convert_request_keys_to: :camelcase
        )
    end

    def wsdl_content
      content = File.join(Rails.root, 'shared', 'wdsl', "CertificateService.wsdl")
    end
    
    def endpoint
      # "http://#{connector_ip}/service/certificateservice"
      return nil unless @connector.kind_of? Connector
      @connector.service("CertificateService")&.endpoint_location(Cocard::CertificateServiceVersion)
    end

    def namespace
      return nil unless @connector.kind_of? Connector
      # 'http://ws.gematik.de/conn/CertificateService/v6.0'
      # sorry, wild hack for Gematik namespace troubles, savon couldn't handle it
      @connector.service("CertificateService")
                &.target_namespace(Cocard::CertificateServiceVersion)
                &.gsub(/WSDL\//, '')
    end

    def namespaces
      {
        # "xmlns:CCTX" => "http://ws.gematik.de/conn/ConnectorContext/v2.0",
        "xmlns:CONN" => "http://ws.gematik.de/conn/ConnectorCommon/v5.0",
        # "xmlns:m2" => "http://ws.gematik.de/conn/CardServiceCommon/v2.0",
       }
    end
  end
end
