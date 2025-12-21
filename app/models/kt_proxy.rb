class KTProxy < ApplicationRecord
  include KTProxyConcerns
  # -- associations
  belongs_to :card_terminal, ->{ unscope(where: :deleted_at) }, optional: true
  belongs_to :ti_client

  # -- configuration
  # -- validations and callbacks
  validates :uuid, :card_terminal_ip, presence: true, uniqueness: true
  validates :incoming_port, uniqueness: { scope: [:incoming_ip] }, presence: true
  validates :outgoing_port, uniqueness: { scope: [:outgoing_ip] } , presence: true
  validates :wireguard_ip, :incoming_ip, :outgoing_ip, presence: true

  def to_s
    "KT-Proxy #{card_terminal_ip}"
  end
end
