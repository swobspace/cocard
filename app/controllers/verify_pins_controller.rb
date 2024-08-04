class VerifyPinsController < ApplicationController
  before_action :set_card_terminal, only: [:verify]

  def index
    @cards = Card.joins(:card_contexts).where("card_contexts.pin_status = 'VERIFIABLE'").distinct
    @card_terminals = CardTerminal.joins(cards: :card_contexts).where("card_contexts.pin_status = 'VERIFIABLE'").distinct
    @connectors = Connector.joins(card_terminals: {cards: :card_contexts}).where("card_contexts.pin_status = 'VERIFIABLE'").distinct
  end

  def verify
    @card_terminal.cards.joins(:card_contexts)
                  .where("card_contexts.pin_status = 'VERIFIABLE'")
                  .distinct.each do |card|
      card.contexts.where("card_contexts.pin_status = 'VERIFIABLE'").each do |cctx|
        # just for debugging
        # result = Cocard::GetPinStatus.new(card: card, context: cctx).call
        result = Cocard::VerifyPin.new(card: card, context: cctx).call

        if result.success?
          status  = :success
          message = (card.to_s + "<br/>" + "Kontext: #{cctx}<br/>" +
                     "VERIFY PIN successful").html_safe
        else
          status  = :alert
          message = (card.to_s + "<br/>" + "Kontext: #{cctx}<br/>ERROR:: " +
                     result.error_messages.join(', ')).html_safe

        end
        Turbo::StreamsChannel.broadcast_prepend_to(
          'verify_pins',
          target: 'toaster',
          partial: "shared/turbo_toast",
          locals: {status: status, message: message})
      end
    end
    Turbo::StreamsChannel.broadcast_prepend_to(
      'verify_pins',
      target: 'toaster',
      partial: "shared/turbo_toast",
      locals: {status: :info, message: "VERIFY PIN für Terminal #{@card_terminal} abgeschlossen"})
    Turbo::StreamsChannel.broadcast_refresh_to(:verify_pins)
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
