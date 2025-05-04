class CardTerminals::ConnectivityCheckJob < ApplicationJob
  queue_as :default

  #
  # Check CardTerminal Configuration and broadcast a toast if problem found
  # CardTerminals::ConnectivityCheckJob.perform_later(card_terminal: card_terminal)
  #
  def perform(options = {})
    options.symbolize_keys!
    card_terminal = options.fetch(:card_terminal)
    status = nil

    if card_terminal.is_accessible?
      if card_terminal.up?
        toaster(card_terminal, :info, "Kartenterminal PING ok")
      else
        toaster(card_terminal, :danger, "Kartenterminal PING failed")
        return false
      end
    else
      toaster(card_terminal, :warning, "PING ist über zugeordnetes Netzwerk deaktiviert")
    end

    # rmi port
    if card_terminal.supports_rmi?
      if card_terminal.tcp_port_open?(card_terminal.rmi_port)
        text = "RMI-Port #{card_terminal.rmi_port} OK"
        toaster(card_terminal, :info, text)
      else
        text = "RMI-Port #{card_terminal.rmi_port} nicht erreichbar, kein Remote Management des Terminals möglich"
        toaster(card_terminal, :alert, text)
      end
    else
      text = "Kartenterminal unterstützt kein RMI"
      toaster(card_terminal, :warning, text)
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
