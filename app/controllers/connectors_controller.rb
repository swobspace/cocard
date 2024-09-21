class ConnectorsController < ApplicationController
  before_action :set_connector, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /connectors
  def index
    if @locatable
      @connectors = @locatable.connectors
    elsif params[:acknowledged]
      @connectors = Connector.acknowledged
    else
      @connectors = Connector.all
    end
    respond_with(@connectors)
  end

  def sindex
    if params[:condition]
      @connectors = Connector.condition(params[:condition]).not_acknowledged
    elsif params[:acknowledged]
      @connectors = Connector.acknowledged
    else
      @connectors = Connector.failed.not_acknowledged
    end
    @pagy, @connectors = pagy(@connectors)
    respond_with(@connectors)
  end

  # GET /connectors/1
  def show
    respond_with(@connector)
  end

  def ping
    respond_with(@connector) do |format|
    end
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

    unless @connector.save
      flash[:alert] = @connector.errors.full_messages.join("; ")
    end
    respond_with(@connector)
  end

  # PATCH/PUT /connectors/1
  def update
    @connector.update(connector_params)
    respond_with(@connector)
  end

  def fetch_sds
    result = ConnectorServices::Fetch.new(connector: @connector).call
    unless result.success?
      @connector.errors.add(:base, :invalid)
      @connector.errors.add(:base, result.error_messages.join("; "))
      flash[:alert] = result.error_messages.join(', ')
    end
    respond_with(@connector, action: :show)
  end

  def get_resource_information
    Cocard::GetResourceInformationJob.perform_now(connector: @connector)
    respond_with(@connector, action: :show)
  end

  def get_card_terminals
    Cocard::GetCardTerminalsJob.perform_now(connector: @connector)
    respond_with(@connector, action: :show)
  end

  def get_cards
    Cocard::GetCardsJob.perform_now(connector: @connector)
    respond_with(@connector, action: :show)
  end

  # DELETE /connectors/1
  def destroy
    @connector.destroy!
    respond_with(@connector, location: polymorphic_path([@loggable, :connectors]))
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
                    :admin_url, :id_contract, :serial, :use_tls, :authentication,
                    location_ids: [],
                    client_certificate_ids: [],
                    connector_contexts_attributes: [
                      :id, :context_id, :_destroy
                    ])

    end
end
