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
      @context   = options.fetch(:context) { @card.context }
    end

    # service.call()
    # do all the work here ;-)
    def call
      error_messages = []
      result = Cocard::SOAP::GetCard.new(
                 connector: connector,
                 mandant: context.mandant,
                 client_system: context.client_system,
                 workplace: context.workplace,
                 iccsn: card.iccsn).call
      if result.success?
        entry = result.response[:get_resource_information_response][:card]
        cc = Cocard::Card.new(entry)
        creator = Cards::Creator.new(connector: connector, cc: cc)
        if creator.save
          ProcessCard.process_card(creator.card)
        end

        Result.new(success?: true, error_messages: error_messages, 
                   card: creator.card)
      else
        Result.new(success?: false, error_messages: result.error_messages, 
                   card: nil)
      end
    end

  private
    attr_reader :connector, :card, :context
  end
end
