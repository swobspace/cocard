module Cards
  class LogsController < LogsController
    before_action :set_loggable

  private
    def set_loggable
      @loggable = Card.find(params[:card_id])
    end

   def add_breadcrumb_show
     # add_breadcrumb_for([set_loggable, @log])
   end

  end
end
