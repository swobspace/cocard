class ConnectorsController < ApplicationController
  before_action :set_connector, only: [:show, :edit, :update, :destroy, :reboot]
  before_action :add_breadcrumb_show, only: [:show]
  after_action :check_config, only: [:show]

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
      @connectors = Connector.condition(params[:condition])
    elsif params[:acknowledged]
      @connectors = Connector.acknowledged
    else
      @connectors = Connector.failed.not_acknowledged
    end
    ordered = @connectors.order(:name)
    @pagy, @connectors = pagy(ordered, count: ordered.count)
    respond_with(@connectors)
  end

  # GET /connectors/1
  def show
    if @connector.contexts.empty?
      flash[:notice] = t('connectors.no_contexts_assigned')
    end
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

  def reboot
    if @connector.rebootable?
      result = Connectors::RMI.new(connector: @connector).call(:reboot)
      if result.success?
        msg = result.response
        flash[:success] = msg
      else
        msg = "Reboot fehlgeschlagen: " + result.response
        flash[:alert] = msg
      end
      Note.create(notable: @connector, user: current_user, message: msg)
    else
      flash[:warning] = "Reboot des Konnektors wird nicht unterstützt"
    end
    respond_with(@connector, action: :show)
  end

  # DELETE /connectors/1
  def destroy
    unless @connector.destroy
      flash[:alert] = @connectors.errors.full_messages.join("; ")
    end
    respond_with(@connector, location: polymorphic_path([@locatable, :connectors]))
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_connector
      @connector = Connector.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def connector_params
      params.require(:connector)
            .permit(:name, :short_name, :ip, :sds_url, :manual_update, :description,
                    :admin_url, :id_contract, :serial, :use_tls, :authentication,
                    :auth_user, :auth_password,
                    location_ids: [],
                    client_certificate_ids: [],
                    connector_contexts_attributes: [
                      :id, :context_id, :_destroy
                    ])
            .reject { |k, v| k == 'auth_password' && v.blank? }

    end
    def check_config
      Connectors::CheckConfigJob.set(wait: 0.5.seconds).perform_later(connector: @connector)
    end
end
