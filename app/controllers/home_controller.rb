class HomeController < ApplicationController
  def index
    @connectors = Connector.failed.order(:name).where(manual_update: false)
    @card_terminals = CardTerminal.warning.order(:name)
    @cards = Card.failed.order(:name)
  end
end
