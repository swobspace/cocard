class Log < ApplicationRecord
  # -- associations
  belongs_to :loggable, polymorphic: true
  default_scope { order('created_at desc') }

  # -- configuration
  # -- validations and callbacks
  validates :action, :last_seen, :level, :message, presence: true


  scope :valid, -> { where(is_valid: true) }
  # -- common methods
  def to_s
    "#{level} - #{loggable.name} >> #{action}: #{message}"
  end

end
