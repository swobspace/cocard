module Cocard
  #
  # Verifies PINs for all Contexts on one card
  # conditions:
  # - card_contexts.pin_status = 'VERIFIABLE'
  # - card_contexts.left_tries = 3 (for safety)
  #
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
      if card.card_terminal&.pin_mode == 'off'
        error_messages = ["SMC-B Auto-PIN-Mode am Kartenterminal ist off!"]
        toaster(card, :alert, error_messages.join(', '))
        return Result.new(success?: false, error_messages: error_messages)
      end

      #
      # update card handle via get_card
      #
      result = Cocard::GetCard.new(card: card, context: card.contexts.first).call

      unless result.success?
        status  = :alert
        message = (card.to_s + "<br/>" + "Kontext: #{card.contexts.first}<br/>ERROR:: " +
                   result.error_messages.join(', ')).html_safe
        toaster(card, status, message)
        return Result.new(success?: false, error_messages: result.error_messages)
      end

      runner = Cocard::PinVerificationRunner.new(card: card)
      coordination_result = runner.verify_contexts do |verifier|
        verify_verifiable_contexts(verifier)
      end

      unless coordination_result.success?
        rmi_error_messages = coordination_result.error_messages
        toaster(card, :alert, (card.to_s + "<br/>ERROR:: " + rmi_error_messages.join(', ')).html_safe)
        return Result.new(success?: false, error_messages: rmi_error_messages)
      end

      verification_error_messages = Array(coordination_result.value)
      Result.new(success?: verification_error_messages.empty?, error_messages: verification_error_messages)
    end

  private
    attr_reader :card

    def verify_verifiable_contexts(verifier)
      error_messages = []
      card.contexts.where("card_contexts.pin_status = 'VERIFIABLE'")
                   .where("card_contexts.left_tries = 3").each do |cctx|
        # just delay for 2 seconds
        sleep 2
        # just for debugging
        # result = Cocard::GetPinStatus.new(card: card, context: cctx).call
        result = verifier.call(cctx)

        if result.success?
          status  = :success
          message = (card.to_s + "<br/>" + "Kontext: #{cctx}<br/>" +
                     "VERIFY PIN successful").html_safe
        else
          status  = :alert
          context_error_messages = Array(result.error_messages)
          error_messages.concat(context_error_messages)
          message = (card.to_s + "<br/>" + "Kontext: #{cctx}<br/>ERROR:: " +
                     context_error_messages.join(', ')).html_safe

        end
        toaster(card, status, message)
        # update card pin status
        Cocard::GetPinStatus.new(card: card, context: cctx).call
      end
      error_messages
    end

    def toaster(card, status, message)
      message = "#{card.name}: #{message}"
      unless status.nil?
        Turbo::StreamsChannel.broadcast_prepend_to(
          'verify_pins',
          target: 'toaster',
          partial: "shared/turbo_toast",
          locals: {status: status, message: message})
      end
    end

  end
end
