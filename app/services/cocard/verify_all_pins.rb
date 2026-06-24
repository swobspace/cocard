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

      if verify_pin_while_supported?
        verification_error_messages = []
        rmi_status = card.card_terminal.rmi.verify_pin_while(card.iccsn) do
          verification_error_messages = verify_verifiable_contexts
        end
        rmi_failed = false
        rmi_error_messages = []
        rmi_status.on_failure do |rmi_message|
          rmi_failed = true
          rmi_error_messages = Array(rmi_message)
          toaster(card, :alert, (card.to_s + "<br/>ERROR:: " + rmi_message).html_safe)
        end
        return Result.new(success?: false, error_messages: rmi_error_messages) if rmi_failed

        verification_error_messages = Array(rmi_status.value || verification_error_messages)
        Result.new(success?: verification_error_messages.empty?, error_messages: verification_error_messages)
      else
        #
        # Background job for auto-enter SMC-B PIN
        #
        CardTerminals::RMI::VerifyPinJob.perform_later(card: card)
        # wait before continue
        sleep 3

        verification_error_messages = verify_verifiable_contexts
        Result.new(success?: verification_error_messages.empty?, error_messages: verification_error_messages)
      end
    end

  private
    attr_reader :card

    def verify_pin_while_supported?
      rmi = card.card_terminal&.rmi
      rmi&.supported? && rmi.available_actions.include?(:verify_pin_while)
    end

    def verify_verifiable_contexts
      error_messages = []
      card.contexts.where("card_contexts.pin_status = 'VERIFIABLE'")
                   .where("card_contexts.left_tries = 3").each do |cctx|
        # just delay for 2 seconds
        sleep 2
        # just for debugging
        # result = Cocard::GetPinStatus.new(card: card, context: cctx).call
        result = verify_pin(cctx)

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

    def verify_pin(context)
      if verify_pin_while_supported?
        Cocard::VerifyPinWithSt1506Retry.new(card: card, context: context).call
      else
        Cocard::VerifyPin.new(card: card, context: context).call
      end
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
