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
      
      @card = Card.find_or_initialize_by(iccsn: cc.iccsn) do |card|
                         Cocard::Card::ATTRIBUTES.each do |attr|
                           next if attr == :iccsn
                           card.send("#{attr}=", cc.send(attr))
                         end
                       end


      #
      # card seen by connector, so must be operational
      #
      unless @card.operational_state&.operational
        @card.operational_state = OperationalState.operational.first
      end

      #
      # Disable this function
      # set context if card.context.nil?
      #
      # if @card.contexts.empty?
      #   @card.card_contexts.build(context_id: ctx.id)
      # end

      if @card.persisted?
        Cocard::Card::ATTRIBUTES.each do |attr|
          @card.send("#{attr}=", cc.send(attr))
        end

        #
        # remove card terminal slot if slotid has changed
        #
        if !@card.slotid.nil? and @card.slotid != cc.slotid
          @card.card_terminal_slot.destroy
        end
      end

      @card.updated_at = Time.current

      Card.suppressing_turbo_broadcasts do
        
        if @card.save
          if !ct.nil? and @card.card_terminal_slot.nil?
            @card.create_card_terminal_slot(card_terminal_id: ct.id, slotid: cc.slotid)
            @card.reload_card_terminal_slot
            @card.update_condition ; @card.save
          end
          true
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
