# frozen_string_literal: true

module Cards
  #
  # Create or update Card
  #
  class Creator
    attr_reader :card

    # creator = Card::Creator(options)
    #
    # mandantory options:
    # * :connector  - connector object
    # * :cc         - Cocard::Card object
    #
    def initialize(options = {})
      options.symbolize_keys
      @connector = options.fetch(:connector)
      @cc        = options.fetch(:cc)
      @card      = nil
    end

    # rubocop:disable Metrics/AbcSize, Rails/SkipsModelValidations
    def save
      #
      # don't store egk and kvk
      #
      return false if cc.iccsn.blank?

      #
      # get card_terminal
      #

      ct = CardTerminal.where(connector_id: connector.id, ct_id: cc.ct_id).first
      
      @card = Card.find_or_initialize_by(iccsn: cc.iccsn) do |card|
                         Cocard::Card::ATTRIBUTES.each do |attr|
                           next if attr == :iccsn
                           card.send("#{attr}=", cc.send(attr))
                         end
                         card.card_terminal_id = ct.id
                       end

      if @card.persisted?
        Cocard::Card::ATTRIBUTES.each do |attr|
          next if attr == :mac
          @card.send("#{attr}=", cc.send(attr))
        end
        @card.card_terminal = ct
        # -- card seen by connector, so must be operational
        unless @card.operational_state&.operational
          @card.operational_state = OperationalState.operational.first
        end
        # -- update condition
        @card.update_condition
      end

      if @card.save
        @card.touch
      else
        Rails.logger.warn("WARN:: could not create or save card #{@card.mac}: " +
          @card.errors.full_messages.join('; '))
        false
      end
    end
    # rubocop:enable Metrics/AbcSize, Rails/SkipsModelValidations

    private

    attr_reader :cc, :connector

  end
end
