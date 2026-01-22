module CardConcerns
  extend ActiveSupport::Concern

  included do
    scope :card_type, -> (card_type) { where('cards.card_type = ?', card_type) }
    scope :smcb, -> { card_type('SMC-B') }
    scope :condition, -> (state) { where('cards.condition = ?', state) }
    scope :ok, -> { condition(Cocard::States::OK) }
    scope :warning, -> { condition(Cocard::States::WARNING) }
    scope :critical, -> { condition(Cocard::States::CRITICAL) }
    scope :unknown, -> { condition(Cocard::States::UNKNOWN) }
    scope :nothing, -> { condition(Cocard::States::NOTHING) }
    scope :failed, -> { where("cards.condition > ?", Cocard::States::OK) }

    scope :current, -> { where("cards.last_check > ?", 7.days.before(Time.current)) }

    scope :verifiable, -> do
      joins(:card_contexts, :operational_state)
      .where("card_contexts.pin_status = 'VERIFIABLE'")
      .where("operational_states.operational = ?", true)
      .distinct
    end

    scope :verifiable_auto, -> do
      joins(:card_contexts, :operational_state, :card_terminal)
      .where("card_terminals.pin_mode = ?", CardTerminal.pin_modes[:auto])
      .where("card_contexts.pin_status = 'VERIFIABLE'")
      .where("card_contexts.left_tries = 3")
      .where("operational_states.operational = ?", true)
      .distinct
    end


    scope :with_description_containing, ->(query) { joins(:rich_text_description).merge(ActionText::RichText.where <<~SQL, "%" + query + "%") }
    body ILIKE ?
   SQL
  end

  def name_or_cardholder
    ( name.blank? ) ? card_holder_name : name
  end

  def certable?
    ['HBA', 'SMC-B'].include?(card_type)
  end

end
