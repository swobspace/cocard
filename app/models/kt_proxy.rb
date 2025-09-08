class KTProxy < ApplicationRecord
  include KTProxyConcerns
  # -- associations
  belongs_to :card_terminal, optional: true
  belongs_to :ti_client

  # -- configuration
  # -- validations and callbacks
  validates :uuid, :card_terminal_ip, presence: true, uniqueness: true
  validates :incoming_port, :outgoing_port, presence: true, uniqueness: true
  validates :wireguard_ip, :incoming_ip, :outgoing_ip, presence: true

end
