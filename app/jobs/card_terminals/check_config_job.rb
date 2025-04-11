class CardTerminals::CheckConfigJob < ApplicationJob
  queue_as :default

  #
  # Check CardTerminal Configuration and broadcast a toast if problem found
  # CardTerminals::CheckConfigJob.perform_later(card_terminal: card_terminal)
  #
  def perform(options = {})
    options.symbolize_keys!
    card_terminal = options.fetch(:card_terminal)
    status = nil

    # check only if card_terminal reachable
    return false unless card_terminal.up?

    # rmi port
    if card_terminal.supports_rmi?
      unless card_terminal.tcp_port_open?(card_terminal.rmi_port)
        text = "RMI-Port #{card_terminal.rmi_port} nicht erreichbar, kein Remote Management des Terminals möglich"
        toaster(card_terminal, :warning, text)
      end
    end

  end

private
  def toaster(card_terminal, status, message)
    unless status.nil?
      Turbo::StreamsChannel.broadcast_prepend_to(
        card_terminal,
        target: 'toaster',
        partial: "shared/turbo_toast",
        locals: {status: status, message: message})
    end
  end
end
