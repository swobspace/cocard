# frozen_string_literal: true

class AutoPinBadgeComponent < ViewComponent::Base
  def initialize(card_terminal:)
    @card_terminal = card_terminal
  end

  def color
    case card_terminal.pin_mode
    when 'off'
      "text-bg-secondary"
    when 'on_demand'
      "text-bg-info"
    when 'auto'
      "text-bg-success"
    else
      "text-bg-warning"
    end
  end

private
  attr_reader :card_terminal
end
