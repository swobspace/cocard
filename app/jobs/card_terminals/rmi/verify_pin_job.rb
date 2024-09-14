module CardTerminals
  module RMI
    class VerifyPinJob < ApplicationJob
      queue_as :rmi

      def perform(options = {})
        options = options.symbolize_keys
        card = options.fetch(:card)
        if check_requirements(card)
          _rmi = @rmi.new(card_terminal: card.card_terminal, iccsn: card.iccsn)
          _rmi.verify_pin
        end
      end

    private
      def check_requirements(card)
        if card.card_type != 'SMC-B'
          Rails.logger.warn(prefix + "Card is not a SMC-B card")
          return false
        end
        if card.card_terminal.nil?
          Rails.logger.warn(prefix + "Card has no card terminal assigned")
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

      def prefix
        "VerifyPinJob:: Card #{card.iccsn}:: "
      end
    end
  end
end
