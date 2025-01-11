class VerifyPinsController < ApplicationController
  before_action :set_card_terminal, only: [:verify]

  def index
    @cards = Card.joins(:card_contexts, :operational_state)
                 .where("card_contexts.pin_status = 'VERIFIABLE'")
                 .where("operational_states.operational = ?", true)
                 .distinct
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
    @card_terminal.cards.joins(:card_contexts, :operational_state)
                  .where("card_contexts.pin_status = 'VERIFIABLE'")
                  .where("operational_states.operational = ?", true)
                  .distinct.each do |card|
      #
      # update card handle via get_card
      #
      result = Cocard::GetCard.new(card: card, context: card.contexts.first).call

      unless result.success?
        status  = :alert
        message = (card.to_s + "<br/>" + "Kontext: #{cctx}<br/>ERROR:: " +
                   result.error_messages.join(', ')).html_safe
        Turbo::StreamsChannel.broadcast_prepend_to(
          'verify_pins',
          target: 'toaster',
          partial: "shared/turbo_toast",
          locals: {status: status, message: message})
      else

        #
        # Auto-enter SMC-B PIN if possible
        #
        if card.card_terminal&.pin_mode == 'on_demand'
          CardTerminals::RMI::VerifyPinJob.perform_later(card: card)
          # wait before continue
          sleep 3
        else
          Turbo::StreamsChannel.broadcast_prepend_to(
            'verify_pins',
            target: 'toaster',
            partial: "shared/turbo_toast",
            locals: {
              status: :warning,
              message: "SMC-B Auto-PIN-Mode in Cocard deaktiviert, bitte PIN am Terminal eingeben"
            }
          )
        end

        #
        # Loop over card contexts
        #
        card.contexts.where("card_contexts.pin_status = 'VERIFIABLE'").each do |cctx|
          # just delay for 2 seconds
          sleep 5
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
          # update card pin status
          Cocard::GetPinStatus.new(card: card, context: cctx).call
        end
      end
    end

    Turbo::StreamsChannel.broadcast_prepend_to(
      'verify_pins',
      target: 'toaster',
      partial: "shared/turbo_toast",
      locals: {status: :info, message: "VERIFY PIN für Terminal #{@card_terminal} abgeschlossen"})
    sleep 1
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
