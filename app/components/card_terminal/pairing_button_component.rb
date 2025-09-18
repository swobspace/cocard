# frozen_string_literal: true

class CardTerminal::PairingButtonComponent < ViewComponent::Base
  def initialize(card_terminal:)
    @card_terminal = card_terminal
  end

  def render?
    card_terminal.supports_rmi? && card_terminal.rmi.available_actions.include?(:remote_pairing)
  end

private
  attr_reader :card_terminal

end
