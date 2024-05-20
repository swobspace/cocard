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
    # Result.new(:success? (Boolean), :error_messages (Array), :cards (Array))
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
        return Result.new(success?: false, error_messages: error_messages, 
                          certificate: nil)
      end

      result = Cocard::SOAP::GetPinStatus.new(
                 card_handle: card.card_handle,
                 connector: connector,
                 mandant: context.mandant,
                 client_system: context.client_system,
                 workplace: context.workplace).call
      if error_messages.blank? and result.success?
        hash = result.response[:get_pin_status_response]
        pin_status = Cocard::PinStatus.new(hash)
        card.pin_status = pin_status.pin_status

        if card.save
          return Result.new(success?: true, error_messages: error_messages, 
                            pin_status: pin_status)
        else
          error_messages << card.errors&.full_messages
        end
      end
      Result.new(success?: false, error_messages: result.error_messages, 
                 certificate: nil)
    end

  private
    attr_reader :connector, :context, :card
  end
end