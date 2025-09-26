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
        error_messages = "SMC-B Auto-PIN-Mode am Kartenterminal ist off!"
        toaster(card, :alert, error_message)
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
      else

        #
        # Background job for auto-enter SMC-B PIN
        #
        CardTerminals::RMI::VerifyPinJob.perform_later(card: card)
        # wait before continue
        sleep 3

        #
        # Loop over card contexts
        #
        card.contexts.where("card_contexts.pin_status = 'VERIFIABLE'")
                     .where("card_contexts.left_tries = 3").each do |cctx|
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
          toaster(card, status, message)
          # update card pin status
          Cocard::GetPinStatus.new(card: card, context: cctx).call
        end
      end
    end

  private
    attr_reader :card

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
