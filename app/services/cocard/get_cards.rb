module Cocard
  #
  # Get resource information from connektor
  #
  class GetCards
    Result = ImmutableStruct.new(:success?, :error_messages, :cards)

    # service = Cocard::GetCards.new(options)
    #
    # mandantory options:
    # * :context - object
    #
    # returns:
    # Result.new(:success? (Boolean), :error_messages (Array), :cards (Array))
    #
    def initialize(options = {})
      options.symbolize_keys
      @connector = options.fetch(:connector)
      @context = options.fetch(:context)
      @mandant   = @context.mandant
      @client_system  = @context.client_system
      @workplace = @context.workplace
    end

    # service.call()
    # do all the work here ;-)
    def call
      connector.touch(:last_check)
      error_messages = []
      cards = []
      result = Cocard::SOAP::GetCards.new(
                 connector: connector,
                 mandant: mandant,
                 client_system: client_system,
                 workplace: workplace).call
      if result.success?
        entry = result.response.dig(:get_cards_response, :cards, :card) || []
        cts = (entry.kind_of? Hash) ? [entry] : entry
        cts.each do |ct|
          card = Cocard::Card.new(ct)
          cards << card
          #
          # Create Card Cards or update
          #
        end
        connector.update(soap_request_success: true,
                         last_ok: Time.current)

        log_error(nil)
        Result.new(success?: true, error_messages: error_messages, 
                   cards: cards)
      else
        connector.update(soap_request_success: false)
        log_error(result.error_messages)
        Result.new(success?: false, error_messages: result.error_messages, 
                   cards: nil)
      end
    end

  private
    attr_reader :connector, :context, :workplace, :mandant, :client_system

    def log_error(message)
      logger = Logs::Creator.new(loggable: connector, level: 'ERROR',
                                 action: 'GetCards', message: message)
      unless logger.call(message.blank?)
        message = Array(message).join('; ')
        Rails.logger.error("could not create log entry: GetCards - #{message}")
      end
    end
  end
end
