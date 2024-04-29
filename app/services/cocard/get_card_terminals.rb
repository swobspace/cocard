module Cocard
  #
  # Get resource information from connektor
  #
  class GetCardTerminals
    Result = ImmutableStruct.new(:success?, :error_messages, :card_terminals)

    # service = Cocard::GetCardTerminals.new(options)
    #
    # mandantory options:
    # * :context - object
    #
    # returns:
    # Result.new(:success? (Boolean), :error_messages (Array), :card_terminals (Array))
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
      card_terminals = []
      result = Cocard::SOAP::GetCardTerminals.new(
                 connector: connector,
                 mandant: mandant,
                 client_system: client_system,
                 workplace: workplace).call
      if result.success?
        entry = result.response[:get_card_terminals_response][:card_terminals][:card_terminal]
        cts = (entry.kind_of? Hash) ? [entry] : entry
        cts.each do |ct|
          card_terminal = Cocard::CardTerminal.new(ct)
          card_terminals << card_terminal
          #
          # Create Card Terminals or update
          #
        end
        connector.update(soap_request_success: true,
                         last_check_ok: Time.current)

        Result.new(success?: true, error_messages: error_messages, 
                   card_terminals: card_terminals)
      else
        connector.update(soap_request_success: false)
        Result.new(success?: false, error_messages: result.error_messages, 
                   card_terminals: nil)
      end
    end

  private
    attr_reader :connector, :context, :workplace, :mandant, :client_system
  end
end
