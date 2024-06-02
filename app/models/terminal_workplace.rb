class TerminalWorkplace < ApplicationRecord
  # -- associations
  belongs_to :card_terminal, optional: false
  belongs_to :workplace, optional: false

  # -- configuration
  # -- validations and callbacks
  validates :workplace_id, 
    presence: true, 
    uniqueness: { 
      scope: [:card_terminal_id, :mandant, :client_system], allow_blank: false 
    }
  validates :card_terminal_id, 
    presence: true, 
    uniqueness: { 
      scope: [:workplace_id, :mandant, :client_system], allow_blank: false 
    }

end
