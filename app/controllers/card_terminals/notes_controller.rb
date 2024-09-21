module CardTerminals
  class NotesController < NotesController
    before_action :set_notable

    private

    def set_notable
      @notable = CardTerminal.find(params[:card_terminal_id])
    end

    def add_breadcrumb_show
      # add_breadcrumb_for([set_notable, @note])
    end
  end
end

