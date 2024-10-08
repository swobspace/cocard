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
              creator = CardTerminals::Creator.new(connector: connector, cct: cct)
              if creator.save
                TerminalWorkplaces::Crupdator.new(
                  card_terminal: creator.card_terminal,
                  mandant: con_ctx.context&.mandant,
                  client_system: con_ctx.context&.client_system,
                  workplaces: cct.workplaces
                ).call
              end
            end
          else
            msg = "WARN:: #{connector.name}: get_card_terminals failed\n" +
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
