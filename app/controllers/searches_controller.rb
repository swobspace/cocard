class SearchesController < ApplicationController
  def index
    @results = (connectors + card_terminals + cards)
    if @results.count > 20
      @results = @results.first(20)
      @info = I18n.t('cocard.to_much_results')
    end

    # render turbo_stream: turbo_stream.replace('show_content', partial: "searches/index")
  end

private

  def connectors
    Connectors::Query.new(Connector.all, search: params[:query]).all
  end

  def card_terminals
    CardTerminals::Query.new(CardTerminal.all, search: params[:query]).all
  end

  def cards
    Cards::Query.new(Card.all, search: params[:query]).all
  end

  def query
    "%#{params[:query]}%"
  end
end
