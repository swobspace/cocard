# frozen_string_literal: true

class CardTerminal::PairingButtonComponent < ViewComponent::Base
  def initialize(card_terminal:)
    @card_terminal = card_terminal
  end

  def title
    if supports_pairing?
      I18n.t('card_terminals.remote_pairing')
    else
      I18n.t('card_terminals.remote_pairing') + " wird ggf. nicht unterstützt"
    end
  end

  def button_class
    if supports_pairing?
      "btn btn-warning me-1"
    else
      "btn btn-outline-warning me-1"
    end

  end

  def confirmation
    if supports_pairing?
      I18n.t('card_terminals.do_remote_pairing') + '?' +
      " - danach bitte Pairingvorgang am Konnektor manuell starten"
    else
      I18n.t('card_terminals.do_remote_pairing') + '?' +
      " !Remote-Pairing wird vom Terminal ggf. nicht unterstützt!"
    end
  end

  def render?
    !card_terminal.connected &&
    card_terminal.supports_rmi? && 
    supports_pairing?
  end

private
  attr_reader :card_terminal

  def supports_pairing?
    card_terminal.rmi.available_actions.include?(:remote_pairing)
  end
end
