class Connector < ApplicationRecord
  # -- associations
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :clients

  # -- configuration
  has_rich_text :description

  # -- validations and callbacks
  validates :ip, presence: true, uniqueness: true
end
