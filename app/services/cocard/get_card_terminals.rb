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
      @connector = options.fetch(:connector)
      @context = options.fetch(:context)
      @mandant   = @context.mandant
      @client_system  = @context.client_system
      @workplace = @context.workplace
      @mandant_wide = options.fetch(:mandant_wide, true)
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
                 workplace: workplace,
                 mandant_wide: @mandant_wide).call
      if result.success?
        entry = result.response&.dig(:get_card_terminals_response, :card_terminals, :card_terminal)
        unless entry.nil?
          cts = (entry.kind_of? Hash) ? [entry] : entry
          cts.each do |ct|
            card_terminal = Cocard::CardTerminal.new(ct)
            card_terminals << card_terminal
            #
            # Create Card Terminals or update
            #
          end
        end
        connector.update(soap_request_success: true)

        log_error(nil)
        Result.new(success?: true, error_messages: error_messages, 
                   card_terminals: card_terminals)
      else
        connector.update(soap_request_success: false)
        log_error(result.error_messages)
        Result.new(success?: false, error_messages: result.error_messages, 
                   card_terminals: nil)
      end
    end

  private
    attr_reader :connector, :context, :workplace, :mandant, :client_system

    def log_error(message)
      logger = Logs::Creator.new(loggable: connector, level: 'ERROR',
                                 action: 'GetCardTerminals', message: message)
      unless logger.call(message.blank?)
        message = Array(message).join('; ')
        Rails.logger.error("could not create log entry: GetCardTerminals - #{message}")
      end
    end

  end
end
