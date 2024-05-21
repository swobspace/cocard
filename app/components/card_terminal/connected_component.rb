# frozen_string_literal: true

class CardTerminal::ConnectedComponent < ViewComponent::Base
  def initialize(card_terminal:)
    @card_terminal = card_terminal
  end

  def message
    if card_terminal.connected
      Cocard::States::flag(Cocard::States::OK) + " Terminal connected"
    else
      Cocard::States::flag(Cocard::States::CRITICAL) + " Terminal not connected!"
    end
  end

private
  attr_reader :card_terminal

end
