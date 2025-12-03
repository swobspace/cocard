module CardTerminals
  class RMI
    class GetInfoJob < ApplicationJob
      queue_as :rmi

      #
      # perform() - all card terminals
      # perform(card_terminal: ct) - specific card terminal
      #
      def perform(options = {})
        options = options.symbolize_keys
        card_terminals = options.fetch(:card_terminal) { CardTerminal.ok.to_a }
        card_terminals = Array(card_terminals)

        if ct.condition == Cocard::States::OK and ct.supports_rmi?
          card_terminals.each do |card_terminal|
            # slow down
            sleep 3
            @prefix = "GetInfo:: card_terminal #{card_terminal}:: ".freeze
            unless check_job_requirements(card_terminal)
              Rails.logger.debug(@prefix + "not all requirements met")
              return false
            end

            card_terminal.rmi.get_info do |result|
              result.on_success do |message, info|
                creator = CardTerminals::RMI::Creator.new(info: info)
                if creator.save
                  Rails.logger.debug(@prefix + "Update des Kartenterminals erfolgreich")
                else
                  Rails.logger.warn(@prefix + "Update des Kartenterminals fehlgeschlagen")
                end
                return true
              end

              result.on_failure do |message|
                Rails.logger.error(@prefix + "RMI-Abfrage fehlgeschlagen: #{message}")
                return false
              end

              result.on_unsupported do
                Rails.logger.warn(@prefix + "Terminal or action not supported")
                return false
              end
            end
          end
        end
      end

      private
        attr_reader :prefix
        def check_job_requirements(card_terminal)
          if !card_terminal.supports_rmi?
            false
          elsif !card_terminal.rmi.available_actions.include?(:get_info)
            false
          else
            true
          end
        end
      end
    end
  end
