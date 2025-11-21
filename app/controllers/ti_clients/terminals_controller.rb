module TIClients
  class TerminalsController < ApplicationController
    skip_load_and_authorize_resource
    load_and_authorize_resource :ti_client

    before_action :set_ticlient

    def index
      success = true
      @terminals = []

      if @rtic.present?
        @rtic.get_terminals do |result|
          result.on_success do |message, value|
            terminals = value['CTM_CT_LIST'] || []
            terminals.each do |terminal|
              @terminals << RISE::TIClient::Konnektor::Terminal.new(terminal)
            end
          end
          result.on_failure do |message|
            flash[:alert] = message
          end
        end
       else
         flash[:warning] = "Zugriff nicht möglich (bitte Einstellungen des TI-Clients prüfen)"
       end

      respond_with(@terminals)
    end

    def assign
      if @rtic.present?
        @rtic.assign(params[:id]) do |result|
          result.on_success do |message, value|
            flash[:success] = message
            if card_terminal.present?
              card_terminal.update(connector_id: @ti_client.connector_id)
            end
          end
          result.on_failure do |message|
            flash[:alert] = message
          end
        end
      else
        flash[:warning] = "Zugriff nicht möglich (bitte Einstellungen des TI-Clients prüfen)"
      end
      fetch_terminal 
      respond_with(@ti_client) do |format|
        format.turbo_stream
      end
    end

    def begin_session
      if @rtic.present?
        @rtic.begin_session(params[:id]) do |result|
          result.on_success do |message, value|
            flash[:success] = message
          end
          result.on_failure do |message|
            flash[:alert] = message
          end
        end
      else
        flash[:warning] = "Zugriff nicht möglich (bitte Einstellungen des TI-Clients prüfen)"
      end
      fetch_terminal 
      respond_with(@ti_client) do |format|
        format.turbo_stream
      end
    end

    def end_session
      if @rtic.present?
        @rtic.end_session(params[:id]) do |result|
          result.on_success do |message, value|
            flash[:success] = message
          end
          result.on_failure do |message|
            flash[:alert] = message
          end
        end
      else
        flash[:warning] = "Zugriff nicht möglich (bitte Einstellungen des TI-Clients prüfen)"
      end
      fetch_terminal 
      respond_with(@ti_client) do |format|
        format.turbo_stream
      end
    end

    def pairing
      # start pairing job
      ct = card_terminal
      if !ct.supports_rmi?
        flash.now[:warning] = unsupported_terminal(ct)
      elsif !ct.tcp_port_open?(ct.rmi_port)
        flash.now[:warning] = rmi_port_unreachable(ct)
      elsif @rtic.present?
        CardTerminals::RMI::RemotePairingJob.perform_later(card_terminal: ct,
                                                           user: current_user)
        Rails.logger.debug("PAIRING:: ctId: #{ct.rawmac.upcase}")
        # -> start connector pairing mode
        @rtic.initialize_pairing(ct.rawmac.upcase) do |init|
          init.on_success do |message, value|
            Rails.logger.debug("PAIRING:: initialize successful, starting finalize with #{value}")
            sleep(2)
            # -> finalize connector pairing mode
            @rtic.finalize_pairing(value) do |fin|
              fin.on_success do |message|
                msg = "Finalize pairing successful: #{message}"
                flash.now[:success] = msg
                Rails.logger.debug(msg)
              end

              fin.on_failure do |message|
                msg = "PAIRING:: finalize failed: #{message}"
                flash.now[:alert] = msg
                Rails.logger.debug(msg)
              end
            end
          end

          init.on_failure do |message|
            flash.now[:alert] = "Initialize pairing failed: #{message}"
            Rails.logger.debug("PAIRING:: initialize failed: #{message}")
          end
        end
      else
        flash[:warning] = "Zugriff nicht möglich (bitte Einstellungen des TI-Clients prüfen)"
      end
      fetch_terminal 
      respond_with(@ti_client) do |format|
        format.turbo_stream
      end
    end

  private
    def set_ticlient
      @ti_client = TIClient.find(params[:ti_client_id])
      if @ti_client&.client_secret.present?
        @rtic = RISE::TIClient::Konnektor::Terminals.new(ti_client: @ti_client)
      end
    end

    def fetch_terminal
      if @rtic.present?
        @rtic.get_terminal(params[:id]) do |result|
          result.on_success do |msg, value|
            @terminal = RISE::TIClient::Konnektor::Terminal.new(value)
          end
        end
      end
    end

    def rmi_port_unreachable(ct)
      msg = "Der RMI-Port des Kartenterminals #{ct.name} ist nicht erreichbar." +
            " Ein Pairing über diese Funktion hier ist nicht möglich." +
            " Bitte Kartenterminal überprüfen und Pairing ggf. über den klassischen" +
            " Weg durchführen: Start Pairing am Konnektor und Eingabe der PIN vor Ort."
    end

    def unsupported_terminal(ct)
      msg = "Laut Cocard unterstützt das Kartenterminal #{ct.name}" +
            " kein Remote-Pairing." +
            " Bitte prüfen Sie das Terminal erneut mit: " +
            ::ActionController::Base.helpers
              .link_to("Kartenterminal aktualisieren",
                       new_duck_terminal_path(
                       identification: ct.identification,
                       firmware_version:
                         (ct.firmware_version.blank? ? '3.9.0' : ct.firmware_version),
                       ip: ct.ip))
      msg.html_safe
    end

    def card_terminal
      if params[:id]
        CardTerminal.where(mac: params[:id]).first
      end
    end

  end
end
