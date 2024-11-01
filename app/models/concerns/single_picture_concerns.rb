module SinglePictureConcerns
  extend ActiveSupport::Concern

  included do
    scope :availability, -> (av) do 
      where('situation_picture.availability = ?', av)
    end
    scope :ok, -> { availability(1) }
    scope :critical, -> { availability(0) }
    scope :failed, -> do
      where("situation_picture.availability <> 1")
    end
  end

end
