# frozen_string_literal: true

class Card::PinStatusComponent < ViewComponent::Base
  def initialize(card:)
    @card = card
  end

  def message
    if card.pin_status == 'VERIFIED'
      Cocard::States.flag(Cocard::States::OK) + " VERIFIED"
    else
      Cocard::States.flag(Cocard::States::CRITICAL) + " #{card.pin_status}"
    end
  end

private
  attr_reader :card

end
