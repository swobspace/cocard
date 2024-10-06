class SituationPictureController < ApplicationController
  def index
    result = ::TI::SituationPicture::Fetch.new().call
    if result.success?
      @situation_picture = result.situation_picture
    else
      @situation_picture = []
      flash[:alert] = "ERROR: TI Lagebild kann nicht abgefragt werden: " +
                      result.error_messages.join('; ')
    end
  end
end
