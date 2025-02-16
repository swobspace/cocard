class Note < ApplicationRecord
  # -- associations
  belongs_to :notable, polymorphic: true
  belongs_to :user, class_name: 'Wobauth::User'

  broadcasts_refreshes

  # -- configuration
  has_rich_text :message
  self.inheritance_column = nil

  enum :type, { plain: 0, acknowledge: 1 }

  # -- validations and callbacks
  validates :user_id, :message, presence: true
  validates :type, inclusion: { in: types.keys }

  # -- common methods

  scope :active, -> do
    where("notes.valid_until >= ? or notes.valid_until IS NULL", Time.current)
  end

  scope :current, -> do
    where('created_at > ?', 21.days.before(Time.current))
  end

  # real objects only, exclude notes from log
  scope :object_notes, -> do
    where(notable_type: ['Connector', 'Card', 'CardTerminal'])
  end

  def to_s
    message.to_plain_text.truncate(80, :ommision => "...")
  end

  def is_active
    valid_until.nil? || valid_until >= Time.current
  end

end
