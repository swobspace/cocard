class Location < ApplicationRecord
  include Taggable
  # -- associations
  has_and_belongs_to_many :connectors
  has_many :card_terminals, dependent: :restrict_with_error
  has_many :cards, dependent: :restrict_with_error
  has_many :networks, dependent: :restrict_with_error

  # -- configuration
  # -- validations and callbacks
  validates :lid, presence: true, 
                   uniqueness: { case_sensitive: false, allow_blank: false }

  # -- common methods
  def to_s
    "#{lid}: #{description}"
  end

end
