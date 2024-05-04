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
      @connector_context = options.fetch(:connector_context)
      @connector = @connector_context.connector
      @mandant   = @connector_context.context.mandant
      @client_system  = @connector_context.context.client_system
      @workplace = @connector_context.context.workplace
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
        entry = result.response[:get_cards_response][:cards][:card]
        cts = (entry.kind_of? Hash) ? [entry] : entry
        cts.each do |ct|
          card = Cocard::Card.new(ct)
          cards << card
          #
          # Create Card Cards or update
          #
        end
        connector.update(soap_request_success: true,
                         last_check_ok: Time.current)

        Result.new(success?: true, error_messages: error_messages, 
                   cards: cards)
      else
        connector.update(soap_request_success: false)
        Result.new(success?: false, error_messages: result.error_messages, 
                   cards: nil)
      end
    end

  private
    attr_reader :connector, :context, :workplace, :mandant, :client_system
  end
end
