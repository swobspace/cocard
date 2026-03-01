class CardTerminalSlot < ApplicationRecord
  # -- associations
  belongs_to :card_terminal
  has_one :card, ->{ unscope(where: :deleted_at) }, dependent: :nullify

  accepts_nested_attributes_for :card
  # -- configuration
  # -- validations and callbacks
  validates_uniqueness_of :slotid, scope: :card_terminal_id
  validates :slotid, presence: true, uniqueness: { scope: :card_terminal_id }
  after_commit :update_card_location
  # -- common methods

  def update_card_location
    if card&.persisted? and ['SMC-B', 'SMC-KT'].include?(card.card_type)
      card.update_column(:location_id, card_terminal&.location_id)
    end
  end
end
