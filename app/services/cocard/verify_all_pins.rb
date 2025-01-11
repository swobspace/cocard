module Cocard
  #
  # Verifies PINs for all Contexts on one card
  # Broadcasts results via TurboStream
  #
  class VerifyAllPins
    Result = ImmutableStruct.new(:success?, :error_messages)

    # service = Cocard::VerifyAllPins.new(options)
    #
    # mandantory options:
    # * :card    - object
    #
    # returns:
    # Result.new(:success? (Boolean), :error_messages (Array))
    #
    def initialize(options = {})
      options.symbolize_keys
      @card          = options.fetch(:card)
    end

    # service.call()
    # do all the work here ;-)
    def call
      error_messages = []
      #
      # update card handle via get_card
      #
      result = Cocard::GetCard.new(card: card, context: card.contexts.first).call

      unless result.success?
        status  = :alert
        message = (card.to_s + "<br/>" + "Kontext: #{cctx}<br/>ERROR:: " +
                   result.error_messages.join(', ')).html_safe
        Turbo::StreamsChannel.broadcast_prepend_to(
          'verify_pins',
          target: 'toaster',
          partial: "shared/turbo_toast",
          locals: {status: status, message: message})
      else

        #
        # Auto-enter SMC-B PIN if possible
        #
        if card.card_terminal&.pin_mode == 'on_demand'
          CardTerminals::RMI::VerifyPinJob.perform_later(card: card)
          # wait before continue
          sleep 3
        else
          Turbo::StreamsChannel.broadcast_prepend_to(
            'verify_pins',
            target: 'toaster',
            partial: "shared/turbo_toast",
            locals: {
              status: :warning,
              message: "SMC-B Auto-PIN-Mode in Cocard deaktiviert, bitte PIN am Terminal eingeben"
            }
          )
        end

        #
        # Loop over card contexts
        #
        card.contexts.where("card_contexts.pin_status = 'VERIFIABLE'").each do |cctx|
          # just delay for 2 seconds
          sleep 2
          # just for debugging
          # result = Cocard::GetPinStatus.new(card: card, context: cctx).call
          result = Cocard::VerifyPin.new(card: card, context: cctx).call

          if result.success?
            status  = :success
            message = (card.to_s + "<br/>" + "Kontext: #{cctx}<br/>" +
                       "VERIFY PIN successful").html_safe
          else
            status  = :alert
            message = (card.to_s + "<br/>" + "Kontext: #{cctx}<br/>ERROR:: " +
                       result.error_messages.join(', ')).html_safe

          end
          Turbo::StreamsChannel.broadcast_prepend_to(
            'verify_pins',
            target: 'toaster',
            partial: "shared/turbo_toast",
            locals: {status: status, message: message})
          # update card pin status
          Cocard::GetPinStatus.new(card: card, context: cctx).call
        end
      end
    end

  private
    attr_reader :card

  end
end
