module CardTerminals
  class RMI
    class SetIdleMessageJob < ApplicationJob
      queue_as :rmi

      #
      # perform(idle_message: idle_message) - all card terminals
      # perform(card_terminal: ct, idle_message: idle_message) - specific card terminal
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
          # single card terminal
          @prefix = "SetIdleMessage:: card_terminal #{card_terminal}:: ".freeze
          unless check_job_requirements(card_terminal)
            Rails.logger.warn(@prefix + "not all requirements met")
            return false
          end
          idle_message = prepare_message(card_terminal, idle_message)

          card_terminal.rmi.set_idle_message(idle_message) do |result|
            result.on_failure do |message|
              Rails.logger.warn("WARN:: #{card_terminal} - " +
                                "could not set idle_message #{message}")
              Turbo::StreamsChannel.broadcast_prepend_to(
                'set_idle_messages',
                target: 'idle_messages',
                partial: "idle_messages/idle_message",
                locals: { card_terminal: card_terminal, success: false })
              return false
            end

            result.on_success do |message|
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

      def prepare_message(ct, msg)
        template = Liquid::Template.parse(msg)
        template.render(ct.to_liquid)
      end
    end
  end
end
