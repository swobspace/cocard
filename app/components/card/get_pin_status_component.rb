# frozen_string_literal: true

class Card::GetPinStatusComponent < ViewComponent::Base
  def initialize(card:, context:)
    @card = card
    @context = context
  end

  def pin_color
    case card.pin_status(context.id)
    when Cocard::States::OK
      "text-success"
    when Cocard::States::CRITICAL
      "text-danger"
    else
      ""
    end
  end

private
  attr_reader :card, :context

end
