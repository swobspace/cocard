class OperationalState < ApplicationRecord
  # -- associations
  has_many :cards

  # -- configuration
  # -- validations and callbacks
  validates :name, presence: true,
                   uniqueness: { case_sensitive: false, allow_blank: false }

  # -- common methods
  scope :operational, -> { where(operational: true) }

  def to_s
    "#{name}"
  end

end
