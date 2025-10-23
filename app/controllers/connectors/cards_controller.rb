module Connectors
  class CardsController < CardsController
    before_action :set_locatable


    def index
      @cards = []
      terminals = @locatable.card_terminals.joins(card_terminal_slots: :card)
                            .where("cards.card_type = 'SMC-B'")
      terminals.each do |term|
         @cards << term.cards.where(card_type: 'SMC-B')
      end
      @cards = @cards.flatten
    end

  private
    def set_locatable
      @locatable = Connector.find(params[:connector_id])
    end

   def add_breadcrumb_show
     # add_breadcrumb_for([set_locatable, @card_terminal])
   end

  end
end
