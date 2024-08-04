class VerifyPinsController < ApplicationController
  def index
    @cards = Card.joins(:card_contexts).where("card_contexts.pin_status = 'VERIFIABLE'").distinct
    @card_terminals = CardTerminal.joins(cards: :card_contexts).where("card_contexts.pin_status = 'VERIFIABLE'").distinct
    @connectors = Connector.joins(card_terminals: {cards: :card_contexts}).where("card_contexts.pin_status = 'VERIFIABLE'").distinct
  end
end
