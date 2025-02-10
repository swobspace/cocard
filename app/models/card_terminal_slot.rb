class CardTerminalSlot < ApplicationRecord
  # -- associations
  belongs_to :card_terminal
  belongs_to :card, optional: true
  # -- configuration
  # -- validations and callbacks
  validates_uniqueness_of :slotid, scope: :card_terminal_id
  validates_uniqueness_of :card_id, allow_nil: true
  before_save :update_card_location
  # -- common methods

  def update_card_location
    if card and ['SMC-B', 'SMC-KT'].include?(card.card_type)
      card.update_column(:location_id, card_terminal&.location_id)
    end
  end
end
