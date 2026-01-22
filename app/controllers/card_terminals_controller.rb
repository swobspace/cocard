class CardTerminalsController < ApplicationController
  skip_load_and_authorize_resource
  before_action :set_card_terminal, only: %i[show edit update destroy
                                             check edit_identification 
                                             edit_idle_message 
                                             fetch_idle_message fetch_proxy
                                             update_idle_message
                                             ping reboot remote_pairing
                                             fetch_card_certificates
                                             test_context_form test_context]
  authorize_resource
  before_action :add_breadcrumb_show, only: [:show]

  # GET /card_terminals
  def index
    if @locatable
      @card_terminals = @locatable.card_terminals
    else
      @card_terminals = CardTerminal.all
    end
    @card_terminals = @card_terminals
                      .left_outer_joins(:location, :connector, card_terminal_slots: :card)
                      .distinct

    @card_terminals = CardTerminals::Query.new(@card_terminals, search_params).all
    @filter = search_params

    respond_with(@card_terminals) do |format|
      format.json { render json: CardTerminalsDatatable.new(@card_terminals, view_context) }
    end
  end

  def sindex
    if params[:condition]
      @card_terminals = CardTerminal.condition(params[:condition])
    elsif params[:acknowledged]
      @card_terminals = CardTerminal.acknowledged
    else
      @card_terminals = CardTerminal.current.failed.not_acknowledged
    end
    ordered = @card_terminals.order('last_ok desc NULLS LAST')
    @pagy, @card_terminals = pagy(ordered, count: ordered.count)
    respond_with(@card_terminals)
  end

  # GET /card_terminals/1
  def show
    @kt_proxy  = @card_terminal.kt_proxy
    @ti_client = @card_terminal.kt_proxy&.ti_client
    fetch_terminal
    check_default_context

    respond_with(@card_terminal)
  end

  def ping
    respond_with(@card_terminal) do |format|
    end
  end

  def check
    CardTerminals::HealthCheckJob.perform_now(card_terminal: @card_terminal,
                                              user: current_user)
    respond_with(@card_terminal) do |format|
      format.turbo_stream { head :ok }
    end
  end

  # GET /card_terminals/new
  def new
    @card_terminal = CardTerminal.new
    respond_with(@card_terminal)
  end

  # GET /card_terminals/1/edit
  def edit
  end

  # POST /card_terminals
  def create
    @card_terminal = CardTerminal.new(card_terminal_params)

    @card_terminal.save
    respond_with(@card_terminal)
  end

  # PATCH/PUT /card_terminals/1
  def update
    @card_terminal.update(card_terminal_params)
    respond_with(@card_terminal)
  end

  def edit_identification
    respond_with(@card_terminal)
  end

  def fetch_idle_message
    unless CardTerminals::RMI::GetIdleMessageJob.perform_now(card_terminal: @card_terminal)
      flash[:alert] = "Abfrage des Ruhebildschirms fehlgeschlagen!"
    end
    redirect_to @card_terminal
  end

  def edit_idle_message
    respond_with(@card_terminal)
  end

  def update_idle_message
    idle_message = idle_message_params['idle_message']

    @card_terminal.rmi.set_idle_message(idle_message) do |result|
      result.on_failure do |message|
        errormsg = "Setzen des Ruhebildschirms fehlgeschlagen!"
        Rails.logger.debug("DEBUG:: update_idle_message: #{errormsg}")
        flash.now[:alert] = errormsg
      end

      result.on_success do |message|
        @card_terminal.update(idle_message: idle_message)
        @card_terminal.reload
      end

      result.on_unsupported do
        flash[:alert] = "Kartenterminal wird nicht unterstützt"
      end
    end

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace(@card_terminal, partial: "card_terminals/show",
                                               locals: { card_terminal: @card_terminal }),
          turbo_stream.update('flash',  partial: "shared/flash_alert")
        ]
      }
    end
  end

  def remote_pairing
    @card_terminal.rmi.remote_pairing do |result|
      result.on_failure do |message|
        errormsg = "Remote Pairing fehlgeschlagen - " + message
        Rails.logger.debug("DEBUG:: remote_pairing: #{errormsg}")
        flash.now[:alert] = errormsg
      end

      result.on_success do |message|
        flash[:success] = "Remote Pairing erfolgreich"
      end

      result.on_unsupported do
        flash[:alert] = "Kartenterminal wird nicht unterstützt"
      end
    end

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace(@card_terminal, partial: "card_terminals/show",
                                               locals: { card_terminal: @card_terminal }),
          turbo_stream.update('flash',  partial: "shared/flash_alert")
        ]
      }
    end
  end

  def reboot
    @card_terminal.rmi.reboot do |result|
      result.on_success do |message|
        flash[:success] = "Reboot gestartet"
      end

      result.on_failure do |message|
        flash[:alert] = "Reboot fehlgeschlagen: " + message
      end

      result.on_unsupported do
        flash[:warning] = "Reboot des Kartenterminals wird nicht unterstützt"
      end
    end

    respond_with(@card_terminal, action: :show)
  end

  def fetch_proxy
    ti_client = @card_terminal&.connector&.ti_client
    if ti_client.present?
      rtic = RISE::TIClient::CardTerminals.new(ti_client: ti_client)
      rtic.get_proxies do |result|
        result.on_success do |message, value|
          proxies = value['proxies'] || []
          proxies.each do |proxy|
            if proxy['cardTerminalIp'] == @card_terminal.ip.to_s ||
               proxy['name'] == @card_terminal.name
               Rails.logger.debug("DEBUG:: fetch_proxy: #{proxy} matches #{@card_terminal}")
              ktp = KTProxies::Crupdator.new(ti_client: ti_client, proxy_hash: proxy)
              if ktp.save
                flash[:success] = "KT-Proxy zugeordnet"
              else
                flash[:alert] = "KT-Proxy konnte nicht angelegt/aktualisiert werden!"
              end
              break
            else
              next
            end
          end
        end
        result.on_failure do |message|
          flash[:alert] = message
        end
      end
    else
      flash[:warning] = "Kein TIClient zugewiesen, kein Abgleich möglich!"
    end
    respond_with(@card_terminal)
  end


  def test_context_form
    @context = @card_terminal.connector&.contexts&.first&.dup || Context.new
    respond_with(@card_terminal)
  end

  def test_context
    if @card_terminal.connector.present?
      context = Context.new(test_context_params)
      ri = Cocard::GetCardTerminals.new(connector: @card_terminal.connector,
                                              context: context,
                                              mandant_wide: false)
      result = ri.call
      if result.success?
        if result.card_terminals.select{|ct| ct.ct_id == @card_terminal.ct_id}.any?
          flash.now[:success] = "Kontext-Test erfolgreich: " + context.to_s
        else
          flash.now[:warning] = "Kontext-Test nur teilweise erfolgreich: Kontext gültig, aber Kartenterminal nicht dem Arbeitplatz zugewiesen"
        end
      else
        flash.now[:alert] = "Kontext-Test fehlgeschlagen! " + result.error_messages.join("; ")
      end
    else
      flash.now[:alert] = "Kein Konnektor zugewiesen, kein Kontext-Test möglich"
    end
    respond_with(@connector) do |format|
      format.turbo_stream
    end
  end

  def new_arp
  end

  def arp_check
    arp = params[:arp_list]
    entries = arp.strip.split(/\n/)
    entries.map{|x| x.split(/\s+/)}.each do |ip,mac|
      next if mac.downcase !~ /[0-9a-f]{2}:/
      ct = CardTerminal.where(mac: mac).first
      if ct.present? and ct.ip.to_s == ip.to_s
        unless params[:only_differences]
          msg = "Kartenterminal #{ct.mac} gefunden, IP #{ip} ok"
          poster(:success, ip, mac, ct, msg) 
        end
      elsif ct.present?
        msg = "Kartenterminal #{ct.mac} gefunden, aber mit abweichender IP #{ip} (Cocard: #{ct.ip})"
        poster(:warning, ip, mac, ct, msg)
      elsif CardTerminal.where(ip: ip).any?
        msg = "Kartenterminal #{mac} per MAC nicht gefunden, aber IP #{ip} existiert in Cocard"
        poster(:warning, ip, mac, ct, msg)
      else
        msg = "Kartenterminal nicht gefunden, weder per MAC #{mac} noch per IP #{ip}"
        poster(:danger, ip, mac, ct, msg)
      end
    end;nil
    render :new_arp
  end

  # DELETE /card_terminals/1
  def destroy
    unless @card_terminal.soft_delete
      flash[:alert] = @card_terminal.errors.full_messages.join("; ")
    end
    respond_with(@card_terminal, location: polymorphic_path([@locatable, :card_terminals]))
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card_terminal
      @card_terminal = CardTerminal.with_deleted.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def card_terminal_params
      params.require(:card_terminal)
            .permit(:tag_list_input,
                    current_ability
                    .permitted_attributes(:update, (@card_terminal||CardTerminal.new)))
            .reject {|k,v| k == 'mac' && v.blank? }

    end

    def idle_message_params
      params.require(:card_terminal).permit(:idle_message)
    end

    def search_params
      searchparms = params.permit(*submit_parms, CardTerminal.attribute_names,
                                  :acknowledged, :with_smcb, :failed, :deleted,
                                  :limit).to_h
      searchparms.reject do |k, v|
        v.blank? || submit_parms.include?(k) || non_search_params.include?(k)
      end
    end

    def submit_parms
      [ "utf8", "authenticity_token", "commit", "format", "view" ]
    end

    def non_search_params
      [ ]
    end


    def test_context_params
      params.require(:context)
            .permit(:mandant, :client_system, :workplace)
    end

    # 
    # RISE TIClient only: fetch terminal
    #

    def fetch_terminal
      @terminal = nil
      if @ti_client and @ti_client.client_secret.present?
        rtic = RISE::TIClient::Konnektor::Terminals.new(
                 ti_client: @card_terminal.kt_proxy.ti_client
               )
        rtic.get_terminal(@card_terminal.rawmac.upcase) do |result|
          result.on_success do |msg, value|
            if value.empty?
              value = { 'CORRELATION' => 'NOTFOUND', 
                        'MAC_ADDRESS' => @card_terminal.rawmac.upcase,
                        'CTID'        => @card_terminal.rawmac.upcase }
            end
            @terminal = RISE::TIClient::Konnektor::Terminal.new(value)
          end
          result.on_failure do |msg|
          end
        end
      end
    end

    def check_default_context
      return unless @card_terminal.connector.present? and @card_terminal.connector.up?
      return if  @card_terminal.last_check.nil?
      return if  @card_terminal.last_check > 15.minutes.before(Time.current)

      context = @card_terminal.connector.contexts.first
      ri = Cocard::GetCardTerminals.new(connector: @card_terminal.connector,
                                        context: context, mandant_wide: false)
      result = ri.call
      if result.success?
        if result.card_terminals.select{|ct| ct.ct_id == @card_terminal.ct_id}.empty?
          flash[:warning] =<<~EOCTX
            Cocard konnte das Kartenterminal nicht in dem Standard-Kontext
            /#{context.plain}/ finden. Prüfen Sie, ob das Kartenterminal
            mit dem Konnektor gepairt und das Kartenterminal dem
            Arbeitplatz und der Arbeitsplatz dem Mandatenen und Client zugewiesen ist.
        EOCTX
        end
      else
        flash[:alert] = "Kontext-Test fehlgeschlagen! " + result.error_messages.join("; ")
      end
    end

    def poster(status, ip, mac, ct, message)
      unless status.nil?
        Turbo::StreamsChannel.broadcast_prepend_to(
          [current_user, :arp_check],
          target: 'arp-checked',
          partial: "card_terminals/arp_entry",
          locals: {status: status, ip: ip, mac: mac, ct: ct, message: message})
      end
    end

end
