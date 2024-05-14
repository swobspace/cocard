class Card < ApplicationRecord
  # -- associations
  belongs_to :card_terminal, optional: true
  belongs_to :context, optional: true
  belongs_to :location, optional: true
  belongs_to :operational_state, optional: true

  # -- configuration
  has_rich_text :description

  # -- validations and callbacks
  validates :iccsn, presence: true, uniqueness: { case_sensitive: false }

  # -- common methods
  def to_s
    "#{iccsn} - #{card_holder_name}"
  end


end
