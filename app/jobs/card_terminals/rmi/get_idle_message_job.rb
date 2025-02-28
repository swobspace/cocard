module CardTerminals
  module RMI
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
            # create one job for each card terminal
            CardTerminals::RMI::GetIdleMessageJob.perform_later(card_terminal: ct)
          end
        else
          @prefix = "GetIdleMessage:: card_terminal #{card_terminal}:: ".freeze
          if check_requirements(card_terminal)
            _rmi = @rmi.new(card_terminal: card_terminal)
            _rmi.get_idle_message
            if _rmi.result['idle_message']
              card_terminal.update(idle_message: _rmi.result['idle_message'])
            end
          end
        end
      end

    private
      attr_reader :prefix
      def check_requirements(card_terminal)
        rmi = CardTerminals::RMI::Base.new(card_terminal: card_terminal)
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
