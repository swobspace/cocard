# frozen_string_literal: true

class Card::GetCardButtonComponent < ViewComponent::Base
  def initialize(card:, force: false)
    @card = card
    @force = force
  end

  def render?
    return false unless ['SMC-B', 'SMC-KT'].include?(card.card_type)
    force or card.card_terminal&.connector&.manual_update
  end

private
  attr_reader :card, :force


end
