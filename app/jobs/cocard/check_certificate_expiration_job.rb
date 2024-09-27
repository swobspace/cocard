module Cocard
  # 
  # Get Certificate Data from Connector SMC-K
  #
  class CheckCertificateExpirationJob < ApplicationJob
    queue_as :default

    def perform(options = {})
      options.symbolize_keys!
      connector = options.fetch(:connector) { Connector.where(manual_update: false).to_a }

      if connector.is_a? Array
        connector.each do |conn|
          # create one job for each connector
          Cocard::CheckCertificateExpirationJob.perform_later(connector: conn)
        end
      else
        Rails.logger.debug("DEBUG:: check certificate expiration from #{connector.name}")
        connector_context = connector.connector_contexts.first

        if connector_context.nil?
           Rails.logger.debug("DEBUG:: #{connector.name}: no connector_context available")
        else
          result = Cocard::CheckCertificateExpiration.new(
                     connector: connector,
                     context: connector_context.context
                   ).call

          if result.success?
            msg = "DEBUG:: #{connector.name}: check certificate expiration successful"
            Rails.logger.debug(msg)
          else
            msg = "WARN:: #{connector.name}: check certificate expiration failed\n" +
                  result.error_messages.join("\n")
            Rails.logger.warn(msg)
          end
        end
      end
    end

    def max_attempts
      0
    end

  end
end
