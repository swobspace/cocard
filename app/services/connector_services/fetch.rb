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
      connector.touch(:last_check)
      begin
        uri = URI(connector.sds_url)
        conn = Faraday.new("#{uri.scheme}://#{uri.host}", 
                           request: { open_timeout: 5, timeout: 10 })
        response = conn.get(uri.path)

        unless response.success?
          # error_messages << response.headers.join(' ')
          error_messages << response.status
          error_messages << response.body
          connector.update(condition: Cocard::States::UNKNOWN)
          log_error(error_messages)
          return Result.new(success?: false, error_messages: error_messages, sds: nil)
        end
      rescue Faraday::Error => e
        error_messages << e.response_status
        error_messages << e.response_headers
        error_messages << e.response_body
        error_messages << e.message
        error_messages.compact!
        connector.update(condition: Cocard::States::CRITICAL)
        log_error(error_messages)
        return Result.new(success?: false, error_messages: error_messages, sds: nil)
      end

      sds = Cocard::SDS.new(response.body)
      if sds.nil?
        error_messages << "No SDS retrieved"
        log_errors("SDS is empty")
        return Result.new(success?: false, error_messages: error_messages, sds: nil)
      end

      connector.connector_services = sds.connector_services
      connector.sds_updated_at     = Time.current
      connector.firmware_version   = connector.product_information&.firmware_version
      final = connector.save
      Result.new(success?: final, error_messages: error_messages, sds: sds.connector_services)
    end
  private
    def log_error(message)
      logger = Logs::Creator.new(loggable: connector, level: 'ERROR', 
                                 action: 'FetchSDS', message: message)
      unless logger.call
        message = Array(message).join('; ')
        Rails.logger.error("could not create log entry: Fetch SDS - #{message}")
      end
    end
  end
end
