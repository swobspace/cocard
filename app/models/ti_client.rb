class TIClient < ApplicationRecord
  # -- associations
  belongs_to :connector, optional: false
  has_many :kt_proxies, dependent: :restrict_with_error

  # -- configuration
  # -- validations and callbacks
  validates :name, presence: true
  validates :url, presence: true, uniqueness: true

  def to_s
    "#{name}"
  end

end
