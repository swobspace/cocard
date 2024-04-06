class Connector < ApplicationRecord
  # -- associations
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :clients

  # -- configuration
  has_rich_text :description

  # -- validations and callbacks
  validates :ip, presence: true, uniqueness: true

  # -- common methods
  def to_s
    "#{_name} / #{ip}"
  end

private
  def _name
    if name.blank?
      "-"
    else
      name
    end
  end
end
