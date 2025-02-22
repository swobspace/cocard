module CardTerminals
  module RMI
    class VerifyPinJob < ApplicationJob
      queue_as :rmi

      def perform(options = {})
        options = options.symbolize_keys
        card = options.fetch(:card)
        @prefix = "VerifyPinJob:: Card #{card.iccsn}:: ".freeze
        if check_requirements(card)
          _rmi = @rmi.new(card_terminal: card.card_terminal)
          _rmi.verify_pin(card.iccsn)
        end
      end

    private
      attr_reader :prefix
      def check_requirements(card)
        if card.card_terminal.nil?
          Rails.logger.warn(prefix + "Card has no card terminal assigned")
          return false
        end
        if card.card_terminal.pin_mode == 'off'
          Rails.logger.warn(prefix + "CardTerminal pin mode == off")
          return false
        end
        if card.card_type != 'SMC-B'
          Rails.logger.warn(prefix + "Card is not a SMC-B card")
          return false
        end

        rmi = CardTerminals::RMI::Base.new(card_terminal: card.card_terminal)
        if !rmi.valid
          Rails.logger.warn(prefix + "CardTerminal does not meet requirements" + 
                            rmi.messages.join(', '))
          false
        else
          @rmi = rmi.rmi
          true
        end
      end
    end
  end
end
