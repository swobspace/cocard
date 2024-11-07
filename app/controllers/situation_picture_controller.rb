class SituationPictureController < ApplicationController
  def index
    if params[:availability]
      @situation_picture = SinglePicture.availability(params[:availability])
    elsif params[:with_failed_tids]
      @situation_picture = SinglePicture.with_failed_tids
    else
      @situation_picture = SinglePicture.all
    end
    respond_with(@situation_picture)
  end

  def failed
    @situation_picture = SinglePicture.with_failed_tids
    @tids = @situation_picture.select(:tid, :availability)
                              .group(:tid).maximum("availability")
  end
end
