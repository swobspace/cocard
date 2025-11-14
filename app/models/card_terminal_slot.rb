class CardTerminalSlot < ApplicationRecord
  # -- associations
  belongs_to :card_terminal
  has_one :card, dependent: :nullify
  # -- configuration
  # -- validations and callbacks
  validates_uniqueness_of :slotid, scope: :card_terminal_id
  after_commit :update_card_location
  # -- common methods

  def update_card_location
    if card&.persisted? and ['SMC-B', 'SMC-KT'].include?(card.card_type)
      card.update_column(:location_id, card_terminal&.location_id)
    end
  end
end
