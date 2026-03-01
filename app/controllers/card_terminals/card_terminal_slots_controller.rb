module CardTerminals
  class CardTerminalSlotsController < CardTerminalSlotsController
    before_action :set_card_terminal

  private

    def set_card_terminal
      @card_terminal = CardTerminal.find(params[:card_terminal_id])
    end

    def add_breadcrumb_show
      # add_breadcrumb_for([set_card_terminal, @note])
    end
  end
end

