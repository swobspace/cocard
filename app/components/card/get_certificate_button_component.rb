# frozen_string_literal: true

class Card::GetCertificateButtonComponent < ViewComponent::Base
  def initialize(card:, force: false)
    @card = card
    @force = force
  end

  def render?
    return false unless card.card_type == 'SMC-B'
    force or (card.card_terminal&.connector&.manual_update and card.certificate.blank?)
  end

private
  attr_reader :card, :force

end
