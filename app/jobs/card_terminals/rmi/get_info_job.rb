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
        card_terminal = options.fetch(:card_terminal) { CardTerminal.ok.to_a }

        if card_terminal.is_a? Array
          card_terminal.each do |ct|
            if ct.condition == Cocard::States::OK and ct.supports_rmi?
              # create one job for each card terminal
              CardTerminals::RMI::GetInfoJob.perform_later(card_terminal: ct)
            end
          end
        else
          # single card terminal
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
