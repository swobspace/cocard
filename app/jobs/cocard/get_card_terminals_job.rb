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
          msg_prefix = "DEBUG:: #{connector.name} - #{con_ctx.context}: "
          msg = msg_prefix + "start fetching card terminals"
          Rails.logger.debug(msg)
          result = Cocard::GetCardTerminals.new(
                     connector: connector,
                     context: con_ctx.context
                   ).call
          if result.success?
            msg = msg_prefix + "fetching card terminals successful"
            Rails.logger.debug(msg)
            result.card_terminals.each do |cct|
              creator = CardTerminals::Creator.new(connector: connector, cct: cct)
              if creator.save
                msg = msg_prefix + "creator save successful"
                Rails.logger.debug(msg)
                TerminalWorkplaces::Crupdator.new(
                  card_terminal: creator.card_terminal,
                  mandant: con_ctx.context&.mandant,
                  client_system: con_ctx.context&.client_system,
                  workplaces: cct.workplaces
                ).call
                msg = msg_prefix + "Workplaces::Crupdator done"
                Rails.logger.debug(msg)
                begin
                  Timeout::timeout(5) do
                    ::CardTerminal.remove_duplicate_ips(creator.card_terminal)
                  end
                rescue
                  msg = msg_prefix + "CardTerminals.remove_duplicate_ips timeout"
                  Rails.logger.warn(msg)
                end
                msg = msg_prefix + "CardTerminals.remove_duplicate_ips done"
                Rails.logger.debug(msg)
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
