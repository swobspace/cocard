# frozen_string_literal: true

class CardTerminal::PairingButtonComponent < ViewComponent::Base
  def initialize(card_terminal:)
    @card_terminal = card_terminal
  end

  def title
    I18n.t('card_terminals.remote_pairing')
  end

  def confirmation
    # I18n.t('card_terminals.do_remote_pairing') + '?'
    I18n.t('card_terminals.do_remote_pairing') + '?' +
    " - danach bitte Pairingvorgang am Konnektor manuell starten"
  end

  def render?
    !card_terminal.connected &&
    card_terminal.supports_rmi? && 
    card_terminal.rmi.available_actions.include?(:remote_pairing)
  end

private
  attr_reader :card_terminal

end
