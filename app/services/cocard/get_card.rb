module Cocard
  include ProcessCard
  #
  # Get card information per icssn
  #
  class GetCard
    Result = ImmutableStruct.new(:success?, :error_messages, :card)

    # service = Cocard::GetCard.new(options)
    #
    # mandantory options:
    # * :card    - object
    # * :context - object
    #
    # returns:
    # Result.new(:success? (Boolean), :error_messages (Array), :cards (Array))
    #
    def initialize(options = {})
      options.symbolize_keys
      @card      = options.fetch(:card)
      @connector = @card.card_terminal&.connector
      @context   = options.fetch(:context)
    end

    # service.call()
    # do all the work here ;-)
    def call
      error_messages = []
      if @card.iccsn.blank?
        error_messages << "No ICCSN available!"
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
                          card: nil)
      end

      result = Cocard::SOAP::GetCard.new(
                 connector: connector,
                 mandant: context&.mandant,
                 client_system: context&.client_system,
                 workplace: context&.workplace,
                 iccsn: card.iccsn).call
      if result.success?
        entry = result.response[:get_resource_information_response][:card]
        cc = Cocard::Card.new(entry)
        creator = Cards::Creator.new(connector: connector, cc: cc)
        if creator.save
          ProcessCard.process_card(creator.card, context)
        end

        log_error(nil)
        Result.new(success?: true, error_messages: error_messages, 
                   card: creator.card)
      else
        log_error(result.error_messages)
        Result.new(success?: false, error_messages: result.error_messages, 
                   card: nil)
      end
    end

  private
    attr_reader :connector, :card, :context

    def log_error(message)
      logger = Logs::Creator.new(loggable: card, level: 'ERROR',
                                 action: 'GetCard', message: message)
      unless logger.call(message.blank?)
        message = Array(message).join('; ')
        Rails.logger.error("could not create log entry: GetCard - #{message}")
      end
    end

  end
end
