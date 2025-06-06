class Tag < ApplicationRecord
  # -- associations
  has_many :taggings, dependent: :destroy
  # -- configuration
  # -- validations and callbacks
  validates :name, presence: true,
                   uniqueness: { case_sensitive: false, allow_blank: false }


  # -- common methods
  def to_s
    "#{name}"
  end


end
