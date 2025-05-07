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
      @ctx       = options.fetch(:context) { nil }
      @card      = nil
    end

    # rubocop:disable Metrics/AbcSize, Rails/SkipsModelValidations
    def save
      #
      # don't store egk and kvk
      #
      return false if cc.iccsn.blank?
      return false if cc.card_type =~ /(EGK|KVK)/ 

      #
      # get card_terminal
      #

      ct = CardTerminal.where(connector_id: connector.id, ct_id: cc.ct_id).first
      #
      # failsafe: CardTerminal may not exist yet or ct_id has changed
      #
      return false if ct.nil?
      
      slot = CardTerminalSlot.find_or_create_by!(card_terminal_id: ct.id, 
                                                 slotid: cc.slotid)
      @card = Card.find_or_initialize_by(iccsn: cc.iccsn) do |card|
                         Cocard::Card::ATTRIBUTES.each do |attr|
                           next if attr == :iccsn
                           card.send("#{attr}=", cc.send(attr))
                         end
                       end

      # remove slot reference from older other card
      if slot.card && slot.card != @card
        slot.card.update(card_terminal_slot_id: nil)
      end
      @card.card_terminal_slot_id = slot.id

      #
      # card seen by connector, so must be operational
      #
      unless @card.operational_state&.operational
        @card.operational_state = OperationalState.operational.first
      end

      if @card.persisted?
        Cocard::Card::ATTRIBUTES.each do |attr|
          @card.send("#{attr}=", cc.send(attr))
        end
      end

      @card.last_check = Time.current

      Card.suppressing_turbo_broadcasts do
        
        if @card.save
          # update condition for new card
          @card.update_condition ; @card.save
        else
          Rails.logger.warn("WARN:: could not create or save card #{@card.iccsn}: " +
            @card.errors.full_messages.join('; '))
          false
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Rails/SkipsModelValidations

    private

    attr_reader :cc, :connector, :ctx

  end
end
