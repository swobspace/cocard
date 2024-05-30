class Log < ApplicationRecord
  # -- associations
  belongs_to :loggable, polymorphic: true

  # -- configuration
  # -- validations and callbacks
  validates :action, :last_seen, :level, :message, presence: true

  # -- common methods
  def to_s
    "#{level} - #{loggable.name} >> #{action}: #{message}"
  end


end
