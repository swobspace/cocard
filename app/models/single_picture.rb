class SinglePicture < ApplicationRecord
  # -- associations
  # -- configuration
  # -- validations and callbacks
  validates :ci, presence: true, 
                   uniqueness: { case_sensitive: false, allow_blank: false }

  # -- common methods
  def to_s
    "#{ci} - #{name}, #{organization}"
  end

end
