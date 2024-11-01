class SituationPictureController < ApplicationController
  def index
    respond_with(@situation_picture)
  end
end
