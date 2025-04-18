class IdleMessagesController < ApplicationController
  def index
  end

  def edit
  end

  def update
    @card_terminals = CardTerminal.ok
    if params[:location_ids]
      @card_terminals = @card_terminals.where(location_id: params[:location_ids])
    end
    if params[:connector_ids]
      @card_terminals = @card_terminals.where(connector_id: params[:connector_ids])
    end
    if params[:card_terminal_ids]
      @card_terminals = @card_terminals.where(id: params[:card_terminal_ids])
    end

    @card_terminals = @card_terminals.to_a

    if @card_terminals.any?
      CardTerminals::RMI::SetIdleMessageJob
      .set(wait: 1.seconds)
      .perform_later(card_terminal: @card_terminals, idle_message: params[:idle_message])
    else
      flash[:notice] = "Keine Kartenterminals mit den angegebene Suchkriterien " +
                       "gefunden, die OK sind!"
    end
    redirect_to idle_messages_url
  end

end
