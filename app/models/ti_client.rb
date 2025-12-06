class TIClient < ApplicationRecord
  include TIClientConcerns
  # -- associations
  belongs_to :connector, optional: false
  has_many :kt_proxies, dependent: :restrict_with_error
  has_many :card_terminals, through: :kt_proxies

  # -- configuration
  encrypts :client_secret

  # -- validations and callbacks
  validates :name, presence: true
  validates :connector_id, :url, presence: true, uniqueness: true

  def to_s
    "#{name}"
  end

  def client_id
    "cocard"
  end

end
