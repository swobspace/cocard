class Network < ApplicationRecord
  include NetworkConcerns
  # -- associations
  belongs_to :location

  # -- configuration
  has_rich_text :description

  # -- validations and callbacks
  validates :netzwerk, presence: true, uniqueness: true

  # -- common methods
  def to_s
    "#{to_cidr_s}"
  end

end
