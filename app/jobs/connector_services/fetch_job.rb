module ConnectorServices
  # 
  # Fetch SDS info from connectors
  #
  class FetchJob < ApplicationJob
    queue_as :default

    def perform(options = {})
      options.symbolize_keys!
      connector = options.fetch(:connector) { Connector.where(manual_update: false).to_a }

      if connector.is_a? Array
        connector.each do |conn|
          # create one job for each connector
          ConnectorServices::FetchJob.perform_later(connector: conn)
        end
      else
        Rails.logger.debug("DEBUG:: fetch connector sds job from #{connector.name}")
        result = ConnectorServices::Fetch.new(connector: connector).call
        if result.success?
          Rails.logger.debug("DEBUG:: #{connector.name}: fetching connector sds successful")
        else
          msg = "WARN:: #{connector.name}: fetch connector sds failed\n" +
                result.error_messages.join("\n")
          Rails.logger.warn(msg)
        end
      end
    end

    def max_attempts
      0
    end

  end
end
