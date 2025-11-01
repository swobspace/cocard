class KTProxiesController < ApplicationController
  before_action :set_kt_proxy, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /kt_proxies
  def index
    filename = "cardterminal_proxies.json"
    if @proxyable
      @kt_proxies = @proxyable.kt_proxies
      filename = "#{@proxyable.to_s}_cardterminal_proxies.json"
    else
      @kt_proxies = KTProxy.all
    end
    respond_with(@kt_proxies) do |format|
      format.json do
        data = render_to_string 'ti_clients/kt_proxies/index'
        send_data data, filename: filename,
                        type: :json,
                        disposition: 'attachment'
      end
    end
  end

  # GET /kt_proxies/1
  def show
    respond_with(@kt_proxy)
  end

  # GET /kt_proxies/new
  def new
    if @proxyable
      @kt_proxy = @proxyable.build_kt_proxy(new_ktproxy_params)
    else
      @kt_proxy = KTProxy.new(new_ktproxy_params)
    end
    respond_with(@kt_proxy)
  end

  # GET /kt_proxies/1/edit
  def edit
  end

  # POST /kt_proxies
  def create
    @kt_proxy = KTProxy.new(kt_proxy_params)
    if @kt_proxy.save
      # create proxy on RISE TIClient
      rtic = RISE::TIClient::CardTerminals.new(ti_client: @kt_proxy.ti_client)
      rtic.create_proxy(@kt_proxy) do |result|
        result.on_success do |message, value|
          flash[:success] = "KTProxy auf TIClient erfolgreich angelegt"
        end
        result.on_failure do |message|
          flash[:alert] = "KTProxy in Cocard angelegt, aber Anlage auf " +
                          "TIClient fehlgeschlagen!" + message
        end
      end

    else
      flash[:alert] = "KTProxy konnte nicht angelegt werden"
    end
    respond_with(@kt_proxy)
  end

  # PATCH/PUT /kt_proxies/1
  def update
    if @kt_proxy.update(kt_proxy_params)
      # update proxy on RISE TIClient
      rtic = RISE::TIClient::CardTerminals.new(ti_client: @kt_proxy.ti_client)
      rtic.update_proxy(@kt_proxy) do |result|
        result.on_success do |message, value|
          flash[:success] = "KTProxy auf TIClient erfolgreich aktualisiert"
        end
        result.on_notfound do
          flash[:warning] = "KTProxy aktualisiert, aber auf TIClient nicht gefunden," +
                            " bitte TIClient prüfen!"
        end
        result.on_failure do |message|
          flash[:alert] = "KTProxy in Cocard aktualisiert, aber Update auf " +
                          "TIClient fehlgeschlagen!" + message
        end
      end

    else
      flash[:alert] = "KTProxy konnte nicht aktualisiert werden"
    end
    respond_with(@kt_proxy)
  end

  # DELETE /kt_proxies/1
  def destroy
    if @kt_proxy.destroy
      # delete proxy on RISE TIClient
      rtic = RISE::TIClient::CardTerminals.new(ti_client: @kt_proxy.ti_client)
      rtic.delete_proxy(@kt_proxy) do |result|
        result.on_success do |message, value|
          flash[:success] = "KTProxy auf TIClient erfolgreich gelöscht"
        end
        result.on_notfound do
          flash[:warning] = "KTProxy gelöscht, aber auf TIClient nicht gefunden," +
                            " bitte TIClient prüfen!"
        end
        result.on_failure do |message|
          flash[:alert] = "KTProxy in Cocard gelöscht, aber Löschen auf " +
                          "TIClient fehlgeschlagen!" + message
        end
      end

    else
      flash[:alert] = "KTProxy konnte nicht gelöscht werden"
    end
    respond_with(@kt_proxy)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kt_proxy
      @kt_proxy = KTProxy.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def kt_proxy_params
      params.require(:kt_proxy)
            .permit(:card_terminal_id, :uuid, :name, :wireguard_ip, 
                    :incoming_ip, :incoming_port, :outgoing_ip, :outgoing_port, 
                    :card_terminal_ip, :card_terminal_port, :ti_client_id)
    end

    def new_ktproxy_params
      Cocard::NewKTProxy.new(card_terminal: @proxyable).attributes
    end
end
