module Cocard::SOAP
  #
  # Base class to be inherited by operation specific classes
  #
  class Base
    # attr_reader :connector

    Result = ImmutableStruct.new(:success?, :error_messages, :response)

    # service = Cocard::SOAP::Base.new(options)
    #
    # mandantory options:
    # * :connector - object
    # * :mandant - string
    # * :client_system_id - string
    # * :workplace_id - string
    #
    def initialize(options = {})
      options.symbolize_keys
      # test for soap operation
      opera = soap_operation
      @connector        = options.fetch(:connector)
      @mandant          = options.fetch(:mandant)
      @client_system_id = options.fetch(:client_system_id)
      @workplace_id     = options.fetch(:workplace_id)
      @savon_client = init_savon_client
    end

    # service.call()
    # do all the work here ;-)
    def call
      error_messages = []
      response = @savon_client
                 .call(soap_operation,
                       :attributes => soap_operation_attributes,
                       message: {
                         "CCTX:Context" => {
                         "CONN:MandantId"      => @mandant,
                         "CONN:ClientSystemId" => @client_system_id,
                         "CONN:WorkplaceId"    => @workplace_id  }})

      # response = Faraday.get(connector.sds_url)
      # unless response.success?
      #   error_messages << response.headers.join(' ')
      #   error_messages << response.status
      #   error_messages << response.body
      #   return Result.new(success?: false, error_messages: error_messages, sds: nil)
      # end
# 
      # sds = Cocard::SDS.new(response.body)
      # if sds.nil?
      #   error_messages << "No SDS retrieved"
      #   return Result.new(success?: false, error_messages: error_messages, sds: nil)
      # end
# 
      # connector.update(connector_services: sds.connector_services)
      # Result.new(success?: true, error_messages: error_messages, sds: sds.connector_services)
    end

    def soap_operation
      raise NotImplementedError, 
            "#{self.class.name} - missing operation, soap_operation is not defined"
    end

    def soap_operation_attributes
      {}
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
      content = File.join(Rails.root, 'shared', 'wdsl', "EventService.wsdl")
    end
    
    def endpoint
      # "http://#{connector_ip}/service/systeminformationservice"
      return nil unless @connector.kind_of? Connector
      @connector.service("EventService")&.endpoint_location(Cocard::EventServiceVersion)
    end

    def namespace
      return nil unless @connector.kind_of? Connector
      # 'http://ws.gematik.de/conn/EventService/v7.2'
      # sorry, wild hack for Gematik namespace troubles, savon couldn't handle it
      @connector.service("EventService")
                &.target_namespace(Cocard::EventServiceVersion)
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
