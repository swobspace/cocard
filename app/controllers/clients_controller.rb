class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /clients
  def index
    @clients = Client.all
    respond_with(@clients)
  end

  # GET /clients/1
  def show
    respond_with(@client)
  end

  # GET /clients/new
  def new
    @client = Client.new
    respond_with(@client)
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients
  def create
    @client = Client.new(client_params)

    @client.save
    respond_with(@client)
  end

  # PATCH/PUT /clients/1
  def update
    @client.update(client_params)
    respond_with(@client)
  end

  # DELETE /clients/1
  def destroy
    @client.destroy!
    respond_with(@client)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def client_params
      params.require(:client).permit(:name, :description)
    end
end
