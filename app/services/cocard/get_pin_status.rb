module Cocard
  #
  # Get resource information from connektor
  #
  class GetPinStatus
    Result = ImmutableStruct.new(:success?, :error_messages, :pin_status)

    # service = Cocard::GetPinStatus.new(options)
    #
    # mandantory options:
    # * :context - object
    # * :card    - object
    #
    # returns:
    # Result.new(:success? (Boolean), :error_messages (Array), :pin_status (String))
    #
    def initialize(options = {})
      options.symbolize_keys
      @card          = options.fetch(:card)
      @context       = options.fetch(:context) { @card.context }
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

      result = Cocard::SOAP::GetPinStatus.new(
                 card_handle: card.card_handle,
                 connector: connector,
                 mandant: context&.mandant,
                 client_system: context&.client_system,
                 workplace: context&.workplace).call
      if result.error_messages.blank? and result.success?
        hash = result.response[:get_pin_status_response]
        pin_status = Cocard::PinStatus.new(hash)
        card.pin_status = pin_status.pin_status

        if card.save
          log_error(nil)
          return Result.new(success?: true, error_messages: error_messages, 
                            pin_status: pin_status)
        else
          error_messages << card.errors&.full_messages
        end
      else
        error_messages = result.error_messages
      end

      log_error(result.error_messages)
      Result.new(success?: false, error_messages: result.error_messages, 
                 pin_status: nil)
    end

  private
    attr_reader :connector, :context, :card

    def log_error(message)
      logger = Logs::Creator.new(loggable: card, level: 'ERROR',
                                 action: 'GetPinStatus', message: message)
      unless logger.call(message.blank?)
        message = Array(message).join('; ')
        Rails.logger.error("could not create log entry: GetPinStatus - #{message}")
      end
    end

  end
end
