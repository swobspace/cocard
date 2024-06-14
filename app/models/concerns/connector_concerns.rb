module ConnectorConcerns
  extend ActiveSupport::Concern

  included do
    scope :condition, -> (state) do 
      where('connectors.condition = ?', state)
      .where(manual_update: false)
    end
    scope :ok, -> { condition(Cocard::States::OK) }
    scope :warning, -> { condition(Cocard::States::WARNING) }
    scope :critical, -> { condition(Cocard::States::CRITICAL) }
    scope :unknown, -> { condition(Cocard::States::UNKNOWN) }
    scope :nothing, -> { condition(Cocard::States::NOTHING) }
    scope :failed, -> do
      where("connectors.condition > ?", Cocard::States::OK)
      .where(manual_update: false)
    end

    scope :with_description_containing, ->(query) { joins(:rich_text_description).merge(ActionText::RichText.where <<~SQL, "%" + query + "%") }
    body ILIKE ?
   SQL

  end
end
