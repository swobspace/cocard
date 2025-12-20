class Log < ApplicationRecord
  include NotableConcerns
  # -- associations
  belongs_to :loggable, polymorphic: true

  default_scope { order('since desc NULLS LAST') }

  # -- configuration
  # -- validations and callbacks
  validates :action, :last_seen, :level, :message, presence: true

  scope :valid, -> { where(is_valid: true) }
  scope :current, -> { where("logs.last_seen > ?", (2*Cocard::grace_period).before(Time.current)) }

  # -- common methods
  def to_s
    "#{level} - #{loggable.name} >> #{action}: #{message}"
  end

end
