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
      # check rmi port
      if card_terminal.tcp_port_open?(card_terminal.rmi_port)
        text = "RMI-Port #{card_terminal.rmi_port} OK"
        toaster(card_terminal, :info, text)
      else
        text = "RMI-Port #{card_terminal.rmi_port} nicht erreichbar, kein Remote Management des Terminals möglich"
        toaster(card_terminal, :alert, text)
      end

      # get_info
      card_terminal.rmi.get_info do |result|
        result.on_success do |message, info|
          if info.terminalname != card_terminal.name
            text = "ACHTUNG: abweichender Terminalname: #{info.terminalname}"
            toaster(card_terminal, :alert, text)
          else
            text = "Terminalname: #{info.terminalname}"
            toaster(card_terminal, :info, text)
          end

          toaster(card_terminal, :info, "DHCP enabled: #{info.dhcp_enabled}")

          if info.macaddr != card_terminal.mac
            text = "ACHTUNG: abweichende MAC-Adresse zu Cocard: #{info.macaddr}"
            toaster(card_terminal, :alert, text)
          else
            text = "MAC: #{info.macaddr}"
            toaster(card_terminal, :info, text)
          end
        end
        result.on_failure do |message|
          text = "RMI-Abfrage fehlgeschlagen: #{message}"
          toaster(card_terminal, :alert, text)
        end
        result.on_unsupported do 
          text = "Kartenterminal unterstützt kein RMI"
          toaster(card_terminal, :warning, text)
        end
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
