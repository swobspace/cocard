class Workplace < ApplicationRecord
  include WorkplaceConcerns
  # -- associations
  has_many :terminal_workplaces, dependent: :destroy
  has_many :card_terminals, through: :terminal_workplaces

  # -- configuration
  has_rich_text :description

  # -- validations and callbacks
  validates :name, presence: true, uniqueness: { case_sensitive: true }

  # -- common methods
  def to_s
    name
  end

end
