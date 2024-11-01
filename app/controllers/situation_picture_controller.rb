class SituationPictureController < ApplicationController
  def index
    if params[:availability]
      @situation_picture = SinglePicture.availability(params[:availability])
    else
      @situation_picture = SinglePicture.all
    end
    respond_with(@situation_picture)
  end
end
