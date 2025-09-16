module CardTerminals
  class RMI
    class GetIdleMessageJob < ApplicationJob
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
              CardTerminals::RMI::GetIdleMessageJob.perform_later(card_terminal: ct)
            end
          end
        else
          # single card terminal
          @prefix = "GetIdleMessage:: card_terminal #{card_terminal}:: ".freeze
          unless check_job_requirements(card_terminal)
            Rails.logger.warn(@prefix + "not all requirements met")
            return false
          end

          card_terminal.rmi.get_idle_message do |result|
            result.on_success do |message, value|
              card_terminal.update(idle_message: value)
              Rails.logger.info("INFO:: #{card_terminal} - " +
                                "idle_message == #{card_terminal.idle_message}")
              return true
            end

            result.on_failure do |message|
              Rails.logger.error(@prefix + "#{message}")
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
        elsif card_terminal.condition != Cocard::States::OK
          Rails.logger.warn(prefix + "CardTerminal condition must be OK, skipping" +
                            rmi.messages.join(', '))
          false
        else
          true
        end
      end
    end
  end
end
