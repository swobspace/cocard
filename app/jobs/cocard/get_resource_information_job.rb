module Cocard
  # 
  # Fetch SDS info from connectors
  #
  class GetResourceInformationJob < ApplicationJob
    queue_as :default

    def perform(options = {})
      options.symbolize_keys!
      connector = options.fetch(:connector) { Connector.where(manual_update: false).to_a }

      if connector.is_a? Array
        connector.each do |conn|
          # create one job for each connector
          Cocard::GetResourceInformationJob.perform_later(connector: conn)
        end
      else
        Rails.logger.debug("DEBUG:: get_resource_information from #{connector.name}")
        connector_context = connector.connector_contexts.first

        if connector_context.nil?
           Rails.logger.debug("DEBUG:: #{connector.name}: no connector_context available")
        else
          result = Cocard::GetResourceInformation.new(
                     connector: connector,
                     context: connector_context.context
                   ).call

          if result.success?
            msg = "DEBUG:: #{connector.name}: get_resource_information successful"
            Rails.logger.debug(msg)
          else
            msg = "WARN:: #{connector.name}: get_resource_information failed\n" +
                  result.error_messages.join("\n")
            Rails.logger.warn(msg)
          end
        end
        Turbo::StreamsChannel.broadcast_refresh_later_to(:home)
      end
    end

    def max_attempts
      0
    end

  end
end
