module Connectors
  class CardTerminalsController < CardTerminalsController
    before_action :set_locatable

  private
    def set_locatable
      @locatable = Connector.find(params[:connector_id])
    end

   def add_breadcrumb_show
     add_breadcrumb_for([set_locatable, @card_terminal])
   end

  end
end
