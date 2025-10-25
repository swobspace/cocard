class TIClientsController < ApplicationController
  before_action :set_ti_client, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /ti_clients
  def index
    @ti_clients = TIClient.all
    respond_with(@ti_clients)
  end

  # GET /ti_clients/1
  def show
    respond_with(@ti_client)
  end

  # GET /ti_clients/new
  def new
    if @connector
      @ti_client = @connector.build_ti_client
    else
      @ti_client = TIClient.new
    end
    respond_with(@ti_client)
  end

  # GET /ti_clients/1/edit
  def edit
  end

  # POST /ti_clients
  def create
    @ti_client = TIClient.new(ti_client_params)

    @ti_client.save
    respond_with(@ti_client)
  end

  # PATCH/PUT /ti_clients/1
  def update
    @ti_client.update(ti_client_params)
    respond_with(@ti_client)
  end

  # DELETE /ti_clients/1
  def destroy
    @ti_client.destroy!
    respond_with(@ti_client)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ti_client
      @ti_client = TIClient.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def ti_client_params
      params.require(:ti_client)
            .permit(:connector_id, :name, :url, :client_secret)
            .reject { |k, v| k == 'client_secret' && v.blank? }
    end
end
