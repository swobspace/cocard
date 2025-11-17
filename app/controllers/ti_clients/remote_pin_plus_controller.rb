module TIClients
  class RemotePinPlusController < ApplicationController
    skip_load_and_authorize_resource
    load_and_authorize_resource :ti_client

    before_action :set_ticlient

    def index
      success = true
      @cards = []
      @configurations = []

      if @rtic.present?
        @rtic.supported_cards do |r1|
          r1.on_success do |message, value|
            cards = value['cards'] || []
            cards.each do |card|
              @cards << RISE::TIClient::RemotePinPlus::Card.new(card)
            end
            @rtic.get_configurations do |r2|
              r2.on_success do |message, value|
                configs = value['configurations'] || []
                configs.each do |config|
                  cfg = RISE::TIClient::RemotePinPlus::Card.new(config)
                  @configurations << cfg
                  update_state(@cards, cfg)
                end
              end
              r2.on_failure do |message|
                flash[:alert] = message
              end
            end
            r1.on_failure do |message|
              flash[:alert] = message
            end
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

    def update_state(cards, cfg)
      iccsn = cfg.iccsn
      cards.select{|c| c.iccsn == iccsn}.first.state = cfg.state
    end

  end
end
