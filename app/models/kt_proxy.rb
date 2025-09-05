class KTProxy < ApplicationRecord
  # -- associations
  belongs_to :card_terminal, optional: true

  # -- configuration
  # -- validations and callbacks
  validates :uuid, :card_terminal_ip, presence: true, uniqueness: true
  validates :wireguard_ip, :incoming_ip, :outgoing_ip,
            :incoming_port, :outgoing_port, presence: true

end
