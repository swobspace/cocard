class CardTerminalSlot < ApplicationRecord
  # -- associations
  belongs_to :card_terminal
  belongs_to :card
  # -- configuration
  # -- validations and callbacks
  validates_uniqueness_of :slot, scope: :card_terminal_id
  validates_uniqueness_of :card_id
  # -- common methods
end
