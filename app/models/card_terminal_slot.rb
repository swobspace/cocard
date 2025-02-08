class CardTerminalSlot < ApplicationRecord
  belongs_to :card_terminal
  belongs_to :card
end
