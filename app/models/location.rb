class Location < ApplicationRecord
  # -- associations
  has_and_belongs_to_many :connectors

  # -- configuration
  # -- validations and callbacks
  validates :lid, presence: true, 
                   uniqueness: { case_sensitive: false, allow_blank: false }

  # -- common methods
  def to_s
    "#{lid}: #{description}"
  end

end
