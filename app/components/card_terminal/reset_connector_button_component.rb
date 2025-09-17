# frozen_string_literal: true

class CardTerminal::ResetConnectorButtonComponent < ViewComponent::Base
  def initialize(card_terminal:)
    @card_terminal = card_terminal
    @connector = @card_terminal.connector
  end

  def render?
    connector.present? && card_terminal.condition != Cocard::States::OK
  end

private
  attr_reader :card_terminal, :connector
end
