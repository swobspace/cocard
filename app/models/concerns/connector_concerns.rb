module ConnectorConcerns
  extend ActiveSupport::Concern

  included do
    scope :ok, -> { where(condition: Cocard::States::OK) }
    scope :warning, -> { where(condition: Cocard::States::WARNING) }
    scope :critical, -> { where(condition: Cocard::States::CRITICAL) }
    scope :unknown, -> { where(condition: Cocard::States::UNKNOWN) }
    scope :nothing, -> { where(condition: Cocard::States::NOTHING) }
    scope :failed, -> { where("connectors.condition <> ?", Cocard::States::OK) }
  end

end
