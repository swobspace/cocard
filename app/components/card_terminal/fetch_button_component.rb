# frozen_string_literal: true

class CardTerminal::FetchButtonComponent < ViewComponent::Base
  def initialize(card_terminal:)
    @card_terminal = card_terminal
    @ti_client     = card_terminal&.connector&.ti_client
  end

  def render?
    ti_client.present? && ti_client.client_secret.present?
  end

private
  attr_reader :card_terminal, :ti_client
end
