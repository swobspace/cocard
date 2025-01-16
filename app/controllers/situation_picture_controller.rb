class SituationPictureController < ApplicationController
  before_action :set_single_picture, only: [:update]

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
    failure_group_ids = SinglePicture
                        .active.current.failed
                        .select(:pdt, :tid)
                        .group(:pdt, :tid)
                        .map{|x| SinglePicture.where(pdt: x.pdt, tid: x.tid).ids}
                        .flatten

    @situation_picture = SinglePicture.where(id: failure_group_ids).active.current

    @failures = @situation_picture.select(:pdt, :tid, :availability)
                                  .group(:pdt, :tid)
                                  .sum("availability")
  end

  # PATCH/PUT /situation_picture/1
  def update
    respond_with(@single_picture) do |format|
      if @single_picture.update(single_picture_params)
        format.turbo_stream
      else
        flash[:alert] = @single_picture.errors.full_messages.join("; ")
        format.html { render :show, status: :unprocessable_entity } 
      end
    end
  end

  private
    def set_single_picture
      @single_picture = SinglePicture.find(params[:id])
    end 
        
    # Only allow a trusted parameter "white list" through.
    def single_picture_params
      params.require(:single_picture).permit(:muted)
    end
    

end
