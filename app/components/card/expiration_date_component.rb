# frozen_string_literal: true

class Card::ExpirationDateComponent < ViewComponent::Base
  def initialize(card:)
    @card = card
  end

  def render?
    !!card
  end

  def message
    if card.expiration_date.blank?
      Cocard::States.flag(Cocard::States::NOTHING)
    elsif card.expiration_date >= 3.month.after(Date.current)
      Cocard::States.flag(Cocard::States::OK) + " #{card.expiration_date}"
    elsif card.expiration_date >= Date.current
      Cocard::States.flag(Cocard::States::WARNING) + " #{card.expiration_date}"
    else
      Cocard::States.flag(Cocard::States::CRITICAL) + " #{card.expiration_date}"
    end
  end

private
  attr_reader :card



end
