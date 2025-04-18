module Cocard
  #
  # Get resource information from connektor
  #
  class VerifyPin
    Result = ImmutableStruct.new(:success?, :error_messages, :pin_verify)

    # service = Cocard::VerifyPin.new(options)
    #
    # mandantory options:
    # * :context - object
    # * :card    - object
    #
    # returns:
    # Result.new(:success? (Boolean), :error_messages (Array), :pin_verify (String))
    #
    def initialize(options = {})
      options.symbolize_keys
      @card          = options.fetch(:card)
      @context       = options.fetch(:context)
      @card_context  = CardContext.where(context_id: @context&.id, card_id: @card.id).first
      @connector     = @card.card_terminal&.connector
    end

    # service.call()
    # do all the work here ;-)
    def call
      error_messages = []
      if @card.card_handle.blank?
        error_messages << "No Card Handle available!"
      end
      if @connector.blank?
        error_messages << "No Connector assigned!"
      end
      if @context.blank?
        error_messages << "No Context assigned!"
      end
      if error_messages.any?
        log_error(error_messages)
        return Result.new(success?: false, error_messages: error_messages, 
                          pin_steatus: nil)
      end

      #
      # Start VerifyPin process
      #
      result = Cocard::SOAP::VerifyPin.new(
                 card_handle: card.card_handle,
                 connector: connector,
                 mandant: context&.mandant,
                 client_system: context&.client_system,
                 workplace: context&.workplace).call

      if result.error_messages.blank? and result.success?
        hash = result.response[:verify_pin_response]
        pin_verify = Cocard::PinVerify.new(hash)

        if pin_verify.pin_result == 'OK'
          success = true
          log_error(nil)
          card_context.update(pin_status: 'VERIFIED')
          return Result.new(success?: true, error_messages: error_messages, 
                            pin_verify: pin_verify)
        else
          if pin_verify.pin_result == 'REJECTED'
            card_context.update(left_tries: pin_verify.left_tries)
          end
          error_messages << pin_verify.pin_result
          error_messages << pin_verify.error_text
          log_error(error_messages)
          return Result.new(success?: false, error_messages: error_messages, 
                            pin_verify: pin_verify)
        end
      else
        error_messages = result.error_messages
      end

      log_error(result.error_messages)
      Result.new(success?: false, error_messages: result.error_messages, 
                 pin_verify: nil)
    end

  private
    attr_reader :connector, :context, :card, :card_context

    def log_error(message)
      logger = Logs::Creator.new(loggable: card, level: 'ERROR',
                                 action: "VerifyPin / #{@context}", message: message)
      unless logger.call(message.blank?)
        message = Array(message).compact.join('; ')
        Rails.logger.error("could not create log entry: VerifyPin - #{message}")
      end
    end

  end
end
