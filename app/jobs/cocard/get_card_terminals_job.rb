module Cocard
  # 
  # Fetch SDS info from connectors
  #
  class GetCardTerminalsJob < ApplicationJob
    queue_as :default

    def perform(options = {})
      options.symbolize_keys!
      connector = options.fetch(:connector) { Connector.where(manual_update: false).to_a }

      if connector.is_a? Array
        connector.each do |conn|
          # create one job for each connector
          Cocard::GetCardTerminalsJob.perform_later(connector: conn)
        end
      else
        Rails.logger.debug("DEBUG:: get_card_terminals from #{connector.name}")

        connector.connector_contexts.each do |con_ctx|
          result = Cocard::GetCardTerminals.new(
                     connector: connector,
                     context: con_ctx.context
                   ).call
          if result.success?
            msg = "DEBUG:: #{connector.name} - #{con_ctx.context}: " +
                  "fetching card terminals successful"
            Rails.logger.debug(msg)
            result.card_terminals.each do |cct|
              CardTerminals::Creator.new(connector: connector, cct: cct).save
            end
          else
            msg = "WARN:: #{connector.name}: fetch connector sds failed\n" +
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
