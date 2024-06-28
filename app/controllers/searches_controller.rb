class SearchesController < ApplicationController
  def index
    @results = (connectors + card_terminals + cards + workplaces)
    if @results.count > 20
      @results = @results.first(20)
      @info = I18n.t('cocard.to_much_results')
    end

    # render turbo_stream: turbo_stream.replace('show_content', partial: "searches/index")
  end

private

  def connectors
    Connectors::Query.new(Connector.all, search: searchstring).all
  end

  def card_terminals
    CardTerminals::Query.new(CardTerminal.all, search: searchstring).all
  end

  def cards
    Cards::Query.new(Card.all, search: searchstring).all
  end

  def workplaces
    Workplace.where("workplaces.name ILIKE ?", query).all
  end

  def query
    "%#{searchstring}%"
  end

  def searchstring
    params[:query].strip
  end
end
