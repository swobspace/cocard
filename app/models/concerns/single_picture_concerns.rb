module SinglePictureConcerns
  extend ActiveSupport::Concern

  included do
    scope :availability, -> (av) do 
      where('situation_picture.availability = ?', av)
      .active
    end
    scope :ok, -> { availability(1) }
    scope :critical, -> { availability(0) }
    scope :failed, -> do
      where("situation_picture.availability <> 1")
      .active
    end
    scope :active, -> { where(muted: false) }

    # SinglePicture.where(tid: SinglePicture.failed.pluck(:tid)).select(:tid, :availability).group(:tid).maximum("availability")
    scope :with_failed_tids, -> {
      where(tid: SinglePicture.failed.pluck(:tid))
      .active
    }
  end

end
