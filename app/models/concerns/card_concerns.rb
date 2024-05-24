module CardConcerns
  extend ActiveSupport::Concern

  included do
    scope :condition, -> (state) { where('cards.condition = ?', state) }
    scope :ok, -> { where(condition: Cocard::States::OK) }
    scope :warning, -> { where(condition: Cocard::States::WARNING) }
    scope :critical, -> { where(condition: Cocard::States::CRITICAL) }
    scope :unknown, -> { where(condition: Cocard::States::UNKNOWN) }
    scope :nothing, -> { where(condition: Cocard::States::NOTHING) }
    scope :failed, -> { where("cards.condition <> ?", Cocard::States::OK) }

    scope :with_description_containing, ->(query) { joins(:rich_text_description).merge(ActionText::RichText.where <<~SQL, "%" + query + "%") }
    body ILIKE ?
   SQL
  end

end
