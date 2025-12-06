module Connectors
  class CardsController < CardsController
    before_action :set_connector


    def index
      @cards = Cards::Query.new(Card.all, connector_id: @connector.id).all
    end

  private
    def set_connector
      @connector = Connector.find(params[:connector_id])
    end

   def add_breadcrumb_show
     # add_breadcrumb_for([set_locatable, @card_terminal])
   end

  end
end
