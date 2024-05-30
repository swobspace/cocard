module CardTerminals
  class LogsController < LogsController
    before_action :set_loggable

  private
    def set_loggable
      @loggable = CardTerminal.find(params[:card_terminal_id])
    end

#    def add_breadcrumb_show
#      add_breadcrumb_for([set_loggable, @log])
#    end

  end
end
