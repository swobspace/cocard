module TIClients
  class RemotePinPlusController < ApplicationController
    skip_load_and_authorize_resource
    load_and_authorize_resource :ti_client

    before_action :set_ticlient

    def index
      success = true
      @cards = []

      if @rtic.present?
        @rtic.get_configurations do |result|
          result.on_success do |message, value|
            cards = value['configurations'] || []
            cards.each do |card|
              @cards << RISE::TIClient::RemotePinPlus::Card.new(card)
            end
          end
          result.on_failure do |message|
            flash[:alert] = message
          end
        end
       else
         flash[:warning] = "Zugriff nicht möglich (bitte Einstellungen des TI-Clients prüfen)"
       end

      respond_with(@cards)
    end

  private
    def set_ticlient
      @ti_client = TIClient.find(params[:ti_client_id])
      if @ti_client&.client_secret.present?
        @rtic = RISE::TIClient::RemotePinPlus.new(ti_client: @ti_client)
      end
    end

  end
end
