class SinglePicture < ApplicationRecord
  include SinglePictureConcerns
  # -- associations
  # -- configuration
  # -- validations and callbacks
  validates :ci, presence: true, 
                   uniqueness: { case_sensitive: false, allow_blank: false }

  # -- common methods
  def to_s
    "#{ci} - #{name}, #{organization}"
  end

  def condition
    if availability == 1
      Cocard::States::OK
    elsif availability == 0
      Cocard::States::CRITICAL
    else
      Cocard::States::UNKNOWN
    end
  end

  def condition_message
    comment.to_s
  end

end
