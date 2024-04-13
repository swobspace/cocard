module ConnectorServices
  #
  # Service fetching connector.sds from connector 
  # and write parsed xml as hash to Connector#properties
  #
  class Fetch
    attr_reader :connector

    Result = ImmutableStruct.new(:success?, :error_messages, :sds)

    # service = ConnectorServices::Fetch.new(connector: connector)
    #
    # mandantory options:
    # * :connector - connector object
    #
    def initialize(options = {})
      options.symbolize_keys
      @connector = options.fetch(:connector)
    end

    # service.call()
    # do all the work here ;-)
    def call
      error_messages = []
      response = Faraday.get(connector.sds_url)
      unless response.success?
        error_messages << response.headers
        error_messages << response.status
        error_messages << response.body
        return Result.new(success: false, error_messages: error_messages, sds: nil)
      end

      sds = Cocard::SDS.new(response.body)
      if sds.nil?
        error_messages << "No SDS retrieved"
        return Result.new(success: false, error_messages: error_messages, sds: nil)
      end

      connector.update(connector_services: sds.connector_services)
    end
  end
end
