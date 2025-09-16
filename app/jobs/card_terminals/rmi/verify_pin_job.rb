module CardTerminals
  class RMI
    class VerifyPinJob < ApplicationJob
      queue_as :rmi

      def perform(options = {})
        options = options.symbolize_keys
        card = options.fetch(:card)
        card_terminal = card.card_terminal
        @prefix = "VerifyPinJob:: Card #{card.iccsn}:: ".freeze
        unless check_job_requirements(card)
          Rails.logger.warn(@prefix + "not all requirements met")
          return false
        end

        card_terminal.rmi.verify_pin(card.iccsn) do |result|
          result.on_success do |message|
            Rails.logger.info(@prefix + "completed")
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

    private
      attr_reader :prefix
      def check_job_requirements(card)
        ct = card.card_terminal
        if ct.nil?
          Rails.logger.warn(prefix + "Card has no card terminal assigned")
          return false
        end
        if ct.pin_mode == 'off'
          Rails.logger.warn(prefix + "CardTerminal pin mode == off")
          return false
        end
        if card.card_type != 'SMC-B'
          Rails.logger.warn(prefix + "Card is not a SMC-B card")
          return false
        end

        if !ct.supports_rmi?
          Rails.logger.warn(prefix + "CardTerminal does not meet requirements")
          false
        else
          true
        end
      end
    end
  end
end
