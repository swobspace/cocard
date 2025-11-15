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
         flash[:warning] = "Kein Client-Secret hinterlegt, keine Abfrage möglich"
       end

      respond_with(@terminals)
    end

    def assign
      if @rtic.present?
        @rtic.assign(params[:ct_id]) do |result|
          result.on_success do |message, value|
            flash[:success] = message
          end
          result.on_failure do |message|
            flash[:alert] = message
          end
        end
       else
         flash[:warning] = "Kein Client-Secret hinterlegt"
       end

      redirect_to ti_client_terminals_path(@ti_client)
    end

    def pairing
      # start pairing job
      card_terminal = CardTerminal.find(params[:card_terminal_id])
      CardTerminals::RMI::RemotePairingJob.perform_later(card_terminal: card_terminal)

      # start connector pairing mode
      #   -> finalize connector pairing mode
    end

  private
    def set_ticlient
      @ti_client = TIClient.find(params[:ti_client_id])
      if @ti_client&.client_secret.present?
        @rtic = RISE::TIClient::Konnektor::Terminals.new(ti_client: @ti_client)
      end
    end

  end
end
