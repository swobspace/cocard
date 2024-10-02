# frozen_string_literal: true

class AutoPinBadgeComponent < ViewComponent::Base
  def initialize(card_terminal:)
    @card_terminal = card_terminal
  end

  def color
    if card_terminal.pin_mode == "off"
      "text-bg-secondary"
    else
      "text-bg-info"
    end
  end

private
  attr_reader :card_terminal
end
