module CardTerminals
  class RMI
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
            if ct.condition == Cocard::States::OK and ct.supports_rmi?
              # create one job for each card terminal
              CardTerminals::RMI::SetIdleMessageJob
              .perform_later(card_terminal: ct, idle_message: idle_message)
            end
          end
        else
          @prefix = "SetIdleMessage:: card_terminal #{card_terminal}:: ".freeze
          if check_requirements(card_terminal)
            idle_message = prepare_message(card_terminal, idle_message)
              @rmi.set_idle_message(idle_message)
   
            if @rmi.result['result'] == 'failure'
              Rails.logger.warn("WARN:: #{card_terminal} - " +
                                "could not set idle_message #{idle_message}")
              Turbo::StreamsChannel.broadcast_prepend_to(
                'set_idle_messages',
                target: 'idle_messages',
                partial: "idle_messages/idle_message",
                locals: { card_terminal: card_terminal, success: false })
              return false

            else
              Rails.logger.info("INFO:: #{card_terminal} - " +
                                "idle_message set to #{idle_message}")
              card_terminal.update(idle_message: idle_message)
              card_terminal.reload
              Turbo::StreamsChannel.broadcast_prepend_to(
                'set_idle_messages',
                target: 'idle_messages',
                partial: "idle_messages/idle_message",
                locals: { card_terminal: card_terminal, success: true })
              return true
            end

          end
        end
      end

    private
      attr_reader :prefix

      def check_requirements(card_terminal)
        rmi = CardTerminals::RMI.new(card_terminal: card_terminal)
        if !rmi.supported?
          Rails.logger.warn(prefix + "CardTerminal does not meet requirements" + 
                            rmi.messages.join(', '))
          false
        elsif card_terminal.condition != Cocard::States::OK
          Rails.logger.warn(prefix + "CardTerminal condition must be OK, skipping" + 
                            rmi.messages.join(', '))
          false
        else
          @rmi = rmi
          true
        end
      end

      def prepare_message(ct, msg)
        template = Liquid::Template.parse(msg)
        template.render(ct.to_liquid)
      end
    end
  end
end
