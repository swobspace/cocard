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

    scope :with_description_containing, ->(query) { joins(:rich_text_description).merge(ActionText::RichText.where <<~SQL, "%" + query + "%") }
    body ILIKE ?
   SQL
  end

  def name_or_cardholder
    ( name.blank? ) ? card_holder_name : name
  end

end
