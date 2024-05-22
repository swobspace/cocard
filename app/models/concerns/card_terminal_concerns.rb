module CardTerminalConcerns
  extend ActiveSupport::Concern

  included do
    scope :condition, -> (state) { where('card_terminals.condition = ?', state) }
    scope :ok, -> { where(condition: Cocard::States::OK) }
    scope :warning, -> { where(condition: Cocard::States::WARNING) }
    scope :critical, -> { where(condition: Cocard::States::CRITICAL) }
    scope :unknown, -> { where(condition: Cocard::States::UNKNOWN) }
    scope :nothing, -> { where(condition: Cocard::States::NOTHING) }
    scope :failed, -> { where("card_terminals.condition <> ?", Cocard::States::OK) }
  end

end
