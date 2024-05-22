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
    Connector.where("name ILIKE :query or CAST(ip AS VARCHAR) ILIKE :query", query: query)
  end

  def card_terminals
    CardTerminal.where("displayname ILIKE :query or CAST(mac AS VARCHAR) ILIKE :query or CAST(ip AS VARCHAR) ILIKE :query", query: query)
  end

  def cards
    Card.where("name ILIKE :query OR iccsn LIKE :query or card_holder_name ILIKE :query", query: query)
  end

  def query
    "%#{params[:query]}%"
  end
end
