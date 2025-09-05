class KTProxiesController < ApplicationController
  before_action :set_kt_proxy, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /kt_proxies
  def index
    @kt_proxies = KTProxy.all
    respond_with(@kt_proxies)
  end

  # GET /kt_proxies/1
  def show
    respond_with(@kt_proxy)
  end

  # GET /kt_proxies/new
  def new
    @kt_proxy = KTProxy.new
    respond_with(@kt_proxy)
  end

  # GET /kt_proxies/1/edit
  def edit
  end

  # POST /kt_proxies
  def create
    @kt_proxy = KTProxy.new(kt_proxy_params)

    @kt_proxy.save
    respond_with(@kt_proxy)
  end

  # PATCH/PUT /kt_proxies/1
  def update
    @kt_proxy.update(kt_proxy_params)
    respond_with(@kt_proxy)
  end

  # DELETE /kt_proxies/1
  def destroy
    @kt_proxy.destroy!
    respond_with(@kt_proxy)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kt_proxy
      @kt_proxy = KTProxy.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def kt_proxy_params
      params.require(:kt_proxy).permit(:card_terminal_id, :uuid, :name, :wireguard_ip, :incoming_ip, :incoming_port, :outgoing_ip, :outgoing_port, :card_terminal_ip, :card_terminal_port)
    end
end
