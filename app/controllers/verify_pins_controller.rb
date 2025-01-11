class VerifyPinsController < ApplicationController
  before_action :set_card_terminal, only: [:verify]

  def index
    @cards = Card.verifiable
    @card_terminals = CardTerminal.joins(cards: [:card_contexts, :operational_state])
                                  .where("card_contexts.pin_status = 'VERIFIABLE'")
                                  .where("operational_states.operational = ?", true)
                                  .distinct
    @connectors = Connector.joins(card_terminals: {cards: [:card_contexts, :operational_state]})
                           .where("card_contexts.pin_status = 'VERIFIABLE'")
                           .where("operational_states.operational = ?", true)
                           .distinct
  end

  def verify
    @card_terminal.cards.verifiable.each do |card|
      Cocard::VerifyAllPins.new(card: card).call
    end

    Turbo::StreamsChannel.broadcast_prepend_to(
      'verify_pins',
      target: 'toaster',
      partial: "shared/turbo_toast",
      locals: {status: :info, message: "VERIFY PIN für Terminal #{@card_terminal} abgeschlossen"})
    sleep 1
    Turbo::StreamsChannel.broadcast_refresh_later_to(:verify_pins)
    Turbo::StreamsChannel.broadcast_refresh_later_to(:home)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card_terminal
      @card_terminal = CardTerminal.find(params[:card_terminal_id])
    end
    
    # Only allow a trusted parameter "white list" through.
    def verify_params
      params.require(:card_terminal_id)
    end

end
