class Log < ApplicationRecord
  # -- associations
  belongs_to :loggable, polymorphic: true

  # -- configuration
  # -- validations and callbacks
  validates :action, :last_seen, :level, :message, presence: true

  # -- common methods
  def to_s
    "#{level}:: #{last_seen.localtime.to_s} #{loggable.name} - #{message}"
  end


end
