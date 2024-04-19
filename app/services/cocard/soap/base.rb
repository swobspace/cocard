module Cocard::SOAP
  #
  # Base class to be inherited by operation specific classes
  #
  class Base
    # attr_reader :connector
    @@soap_operation = nil
    @@attributes = {}

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
      @connector        = options.fetch(:connector)
      @mandant          = options.fetch(:mandant)
      @client_system_id = options.fetch(:client_system_id)
      @workplace_id     = options.fetch(:workplace_id)
      if @@soap_operation.nil?
        raise NotImplementedError, "#{self.class.name} - missing class variable @@soap_action"
      end
      @savon_client = init_savon_client
    end

    # service.call()
    # do all the work here ;-)
    def call
      error_messages = []
      response = @savon_client
                 .call(@@soap_operation,
                       :attributes => @@attributes,
                       message: {
                         "m0:Context" => {
                         "m1:MandantId"      => @mandant,
                         "m1:ClientSystemId" => @client_system_id,
                         "m1:WorkplaceId"    => @workplace_id  }})

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
      @connector.service("EventService").endpoint_location(Cocard::EventServiceVersion)
    end

    def namespace
      'http://ws.gematik.de/conn/EventService/v7.2'
      # @connector.service("EventService").target_namespace(Cocard::EventServiceVersion)
    end

    def namespaces
      {
        # "xmlns:m" => 'http://ws.gematik.de/conn/EventService/v7.2',
        "xmlns:m0" => "http://ws.gematik.de/conn/ConnectorContext/v2.0",
        "xmlns:m1" => "http://ws.gematik.de/conn/ConnectorCommon/v5.0",
        # "xmlns:m2" => "http://ws.gematik.de/conn/CardServiceCommon/v2.0",
       }
    end
  end
end
