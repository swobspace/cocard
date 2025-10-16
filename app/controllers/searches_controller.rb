class SearchesController < ApplicationController
  def index
    @results = (connectors + card_terminals + cards + workplaces + kt_proxies)
    if @results.count > 20
      @results = @results.first(20)
      @info = I18n.t('cocard.to_much_results')
    end

    # render turbo_stream: turbo_stream.replace('show_content', partial: "searches/index")
  end

private

  def connectors
    # Connectors::Query.new(Connector.all, search: searchstring).all
    relation = Connector.all
    Connectors::Query.new(relation, searchopts).all.distinct
  end

  def card_terminals
    # CardTerminals::Query.new(CardTerminal.all, search: searchstring).all
    relation = CardTerminal.left_outer_joins(:location, :connector,
                                             card_terminal_slots: :card)
    CardTerminals::Query.new(relation, searchopts).all.distinct
  end

  def cards
    # Cards::Query.new(Card.all, search: searchstring).all
    relation =  Card.left_outer_joins(:location, :operational_state)
    Cards::Query.new(relation, searchopts).all.distinct
  end

  def workplaces
    Workplace.where("workplaces.name ILIKE ?", query).all
  end

  def kt_proxies
    return [] unless Cocard.enable_ticlient
    relation = KTProxy.all
    KTProxies::Query.new(relation, searchopts).all.distinct
  end

  def query
    "%#{searchstring}%"
  end

  def searchstring
    params[:query]&.strip
  end

  def quarry
    searchstring.split(/\s+/)
  end

  def searchopts
    search_opts = {}
    # process named options first
    opts = quarry.select{|x| x =~ /:/}
    opts.each do |opt|
      (k,v) = opt.split(/:/)
      search_opts[k.downcase] = v
    end
    # add search for simple string
    search_opts[:search] = (quarry - opts).first
    search_opts
  end
end
