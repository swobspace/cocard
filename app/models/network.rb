class Network < ApplicationRecord
  include NetworkConcerns
  # -- associations
  belongs_to :location
  has_many :card_terminals, dependent: :nullify

  # -- configuration
  has_rich_text :description

  enum :accessibility, { nothing: -1, ping: 0 }

  # -- validations and callbacks
  validates :netzwerk, presence: true, uniqueness: true

  # -- common methods
  def to_s
    "#{to_cidr_s}"
  end

end
