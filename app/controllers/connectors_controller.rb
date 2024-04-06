class ConnectorsController < ApplicationController
  before_action :set_connector, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /connectors
  def index
    @connectors = Connector.all
    respond_with(@connectors)
  end

  # GET /connectors/1
  def show
    respond_with(@connector)
  end

  # GET /connectors/new
  def new
    @connector = Connector.new
    respond_with(@connector)
  end

  # GET /connectors/1/edit
  def edit
  end

  # POST /connectors
  def create
    @connector = Connector.new(connector_params)

    @connector.save
    respond_with(@connector)
  end

  # PATCH/PUT /connectors/1
  def update
    @connector.update(connector_params)
    respond_with(@connector)
  end

  # DELETE /connectors/1
  def destroy
    @connector.destroy!
    respond_with(@connector)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_connector
      @connector = Connector.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def connector_params
      params.require(:connector)
            .permit(:name, :ip, :sds_url, :manual_update, :description,
                    client_ids: [], location_ids: [])
 
    end
end
