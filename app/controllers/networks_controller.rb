class NetworksController < ApplicationController
  before_action :set_network, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /networks
  def index
    @networks = Network.all
    respond_with(@networks)
  end

  # GET /networks/1
  def show
    respond_with(@network)
  end

  # GET /networks/new
  def new
    @network = Network.new
    respond_with(@network)
  end

  # GET /networks/1/edit
  def edit
  end

  # POST /networks
  def create
    @network = Network.new(network_params)

    @network.save
    respond_with(@network)
  end

  # PATCH/PUT /networks/1
  def update
    @network.update(network_params)
    respond_with(@network)
  end

  # DELETE /networks/1
  def destroy
    @network.destroy!
    respond_with(@network)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_network
      @network = Network.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def network_params
      params.require(:network).permit(:netzwerk, :description, :location_id)
    end
end
