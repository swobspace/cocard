class SituationPictureController < ApplicationController
  def index
    result = ::TI::SituationPicture::Fetch.new().call
    if result.success?
      @situation_picture = result.situation_picture
    end
  end
end
