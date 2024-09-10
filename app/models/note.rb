class Note < ApplicationRecord
  # -- associations
  belongs_to :notable, polymorphic: true
  belongs_to :user, class_name: 'Wobauth::User'

  # -- configuration
  has_rich_text :message
  self.inheritance_column = nil

  enum type: { plain: 0, acknowledge: 1 }

  # -- validations and callbacks
  validates :user_id, :message, presence: true
  validates :type, inclusion: { in: types.keys }

  after_create :update_acknowledge
  before_destroy :remove_acknowledge

  # -- common methods

  scope :active, -> do
    where("notes.valid_until >= ? or notes.valid_until IS NULL", Time.current)
  end

  def to_s
    message.to_plain_text.truncate(80, :ommision => "...")
  end

  def is_active
    valid_until.nil? || valid_until >= Time.current
  end

private
  def update_acknowledge
    if type == Note.types[:acknowledge]
      self.notable.update(acknowledge_id: self.id)
    end
  end

  def remove_acknowledge
    if type == Note.types[:acknowledge]
      self.notable.update(acknowledge_id: nil)
    end
  end
end
