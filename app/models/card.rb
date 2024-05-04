class Card < ApplicationRecord
  # -- associations
  belongs_to :card_terminal

  # -- configuration
  has_rich_text :description

  # -- validations and callbacks
  validates_uniqueness_of :iccsn, case_sensitive: false

  # -- common methods
  def to_s
    "#{iccsn} - #{card_holder_name}"
  end


end
