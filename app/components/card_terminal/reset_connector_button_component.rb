# frozen_string_literal: true

class CardTerminal::ResetConnectorButtonComponent < ViewComponent::Base
  def initialize(card_terminal:)
    @card_terminal = card_terminal
    @connector = @card_terminal.connector
  end

  def render?
    connector.present? && ( card_terminal.condition != Cocard::States::OK ||
                            card_terminal.last_check.nil? ||
                            card_terminal.last_check < 14.days.before(Date.current) )
  end

private
  attr_reader :card_terminal, :connector
end
