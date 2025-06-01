class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /locations
  def index
    @locations = Location.all
    respond_with(@locations)
  end

  # GET /locations/1
  def show
    respond_with(@location)
  end

  # GET /locations/new
  def new
    @location = Location.new
    respond_with(@location)
  end

  # GET /locations/1/edit
  def edit
  end

  # POST /locations
  def create
    @location = Location.new(location_params)

    @location.save
    respond_with(@location)
  end

  # PATCH/PUT /locations/1
  def update
    @location.update(location_params)
    respond_with(@location)
  end

  # DELETE /locations/1
  def destroy
    unless @location.destroy
      flash[:alert] = @location.errors.full_messages.join("; ")
    end
    respond_with(@location)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = Location.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def location_params
      params.require(:location).permit(:lid, :description, :tag_list_input)
    end
end
