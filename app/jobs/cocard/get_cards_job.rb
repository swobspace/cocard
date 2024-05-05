module Cocard
  # 
  # Fetch SDS info from connectors
  #
  class GetCardsJob < ApplicationJob
    queue_as :default

    def perform(options = {})
      options.symbolize_keys!
      connector = options.fetch(:connector) { Connector.where(manual_update: false).to_a }

      if connector.is_a? Array
        connector.each do |conn|
          # create one job for each connector
          Cocard::GetCardsJob.perform_later(connector: conn)
        end
      else
        Rails.logger.debug("DEBUG:: get_cards from #{connector.name}")

        connector.connector_contexts.each do |con_ctx|
          result = Cocard::GetCards.new(
                     connector_context: con_ctx
                   ).call
          if result.success?
            msg = "DEBUG:: #{connector.name} - #{con_ctx.context}: " +
                  "fetching card successful"
            Rails.logger.debug(msg)
            result.cards.each do |card|
              Cards::Creator.new(connector: connector, cc: card).save
            end
          else
            msg = "WARN:: #{connector.name}: get cards failed\n" +
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
