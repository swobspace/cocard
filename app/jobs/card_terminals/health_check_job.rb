class CardTerminals::HealthCheckJob < ApplicationJob
  queue_as :default

  def perform(options = {})
    options.symbolize_keys!
    card_terminal = options.fetch(:card_terminal)
    @user         = options.fetch(:user)
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
        return false
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

          if info.macaddr != card_terminal.mac
            text = "ACHTUNG: abweichende MAC-Adresse zu Cocard: #{info.macaddr}"
            toaster(card_terminal, :alert, text)
          else
            text = "MAC: #{info.macaddr}"
            toaster(card_terminal, :info, text)
          end

          if info.smckt_slot == 0
            text = "ACHTUNG: keine SMC-KT erkannt, bitte Terminal prüfen"
            toaster(card_terminal, :alert, text)
          end

          # check_value(card_terminal, info, :dhcp_enabled)
          # check_value(card_terminal, info, :ntp_server)
          # check_value(card_terminal, info, :ntp_enabled)
          # check_value(card_terminal, info, :tftp_server)
          # check_value(card_terminal, info, :tftp_file)

          #
          # Update card terminal
          #
          
          creator = CardTerminals::RMI::Creator.new(info: info)
          creator.save
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
        @user,
        target: 'toaster',
        partial: "shared/turbo_toast",
        locals: {status: status, message: message})
    end
  end

  def check_value(card_terminal, info, attrib)
    decorated = CardTerminals::RMI::InfoDecorator.new(info)
    value = info.send(attrib)
    text = I18n.t('card_terminals.rmi.' + attrib.to_s) + ': ' + value.to_s

    case decorated.send("#{attrib}_ok?")
    when Cocard::States::NOTHING
      return
    when Cocard::States::OK
      status = :info
    else
      text += " \u2260 #{decorated.send("#{attrib}_default").to_s}!"
      status = :warning
    end
    toaster(card_terminal, status, text)
  end

end
