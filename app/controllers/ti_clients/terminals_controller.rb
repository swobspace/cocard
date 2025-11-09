module TIClients
  class TerminalsController < ApplicationController
    skip_load_and_authorize_resource
    before_action :set_ticlient

    def index
      success = true
      @terminals = []

      if @ti_client.client_secret.present?
        rtic = RISE::TIClient::Konnektor::Terminals.new(ti_client: @ti_client)
        rtic.get_terminals do |result|
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

  private
    def set_ticlient
      @ti_client = TIClient.find(params[:ti_client_id])
    end

    def add_breadcrumb_index
    end

  end
end
