class Client < ApplicationRecord
  # -- associations
  has_and_belongs_to_many :connectors

  # -- configuration
  # -- validations and callbacks
  validates :name, presence: true, 
                   uniqueness: { case_sensitive: false, allow_blank: false }

  # -- common methods
  def to_s
    "#{name}"
  end

end
