# frozen_string_literal: true

class Card::PinStatusComponent < ViewComponent::Base
  def initialize(card:)
    @card = card
  end

  def messages
    msg = []
    card.card_contexts.each do |cx|
      if cx.pin_status == 'VERIFIED'
        msg << Cocard::States.flag(Cocard::States::OK) + " #{cx.context} VERIFIED"
      else
        msg << Cocard::States.flag(Cocard::States::CRITICAL) + " #{cx.context} #{cx.pin_status}"
      end
    end
    msg
  end

private
  attr_reader :card

end
