module CardTerminals
  module RMI
    class SetIdleMessageJob < ApplicationJob
      queue_as :rmi

      #
      # perform() - all card terminals
      # perform(card_terminal: ct) - specific card terminal
      #
      def perform(options = {})
        options = options.symbolize_keys
        card_terminal = options.fetch(:card_terminal) { CardTerminal.ok.to_a }
        idle_message  = options.fetch(:idle_message)

        if card_terminal.is_a? Array
          card_terminal.each do |ct|
            # create one job for each card terminal
            CardTerminals::RMI::SetIdleMessageJob
            .perform_later(card_terminal: ct, idle_message: idle_message)
          end
        else
          @prefix = "SetIdleMessage:: card_terminal #{card_terminal}:: ".freeze
          if check_requirements(card_terminal)
            _rmi = @rmi.new(card_terminal: card_terminal)
            idle_message = prepare_message(idle_message)
            _rmi.set_idle_message(idle_message)
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

      def prepare_message(msg)
        template = Liquid::Template.parse(msg)
        template.render(to_liquid)
      end
    end
  end
end
