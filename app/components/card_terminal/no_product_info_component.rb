# frozen_string_literal: true

class CardTerminal::NoProductInfoComponent < ViewComponent::Base
  def initialize(card_terminal:)
    @card_terminal = card_terminal
  end

  def render?
    card_terminal.properties.nil?
  end

private
  attr_reader :card_terminal
end
