module Cocard
  class NewKTProxy

    def initialize(options)
      @options  = options.symbolize_keys
      @card_terminal = options.fetch(:card_terminal)
      @ti_client = options.fetch(:ti_client) { nil }
      @defaults = options.fetch(:defaults) { Cocard.ktproxy_defaults }
    end

    def attributes
      {
        ti_client_id: ti_client_id,
        card_terminal_id: card_terminal&.id,
        uuid: SecureRandom.uuid,
        name: card_terminal&.displayname,
        wireguard_ip: defaults['wireguard_ip'],
        incoming_ip: defaults['incoming_ip'],
        incoming_port: new_incoming_port,
        outgoing_ip: defaults['outgoing_ip'],
        outgoing_port: new_outgoing_port,
        card_terminal_ip: card_terminal_ip,
        card_terminal_port: defaults['card_terminal_port']
      }
    end

  private
    attr_reader :defaults, :options, :card_terminal, :ti_client

    def new_incoming_port
      port = Cocard::KTProxy::Port.new(
               port_range: defaults['incoming_port_range'],
               used_ports: ::KTProxy.all.pluck(:incoming_port)).next_port
      ( port > 0 ) ? port.to_s : ""
    end

    def new_outgoing_port
      port = Cocard::KTProxy::Port.new(
               port_range: defaults['outgoing_port_range'],
               used_ports: ::KTProxy.all.pluck(:outgoing_port)).next_port
      ( port > 0 ) ? port.to_s : ""
    end

    def card_terminal_ip
      return nil unless card_terminal.present?
      if card_terminal_ip_blacklist.include?(card_terminal.ip.to_s)
        nil
      else
        card_terminal.ip.to_s
      end
    end

    def card_terminal_ip_blacklist
      [
        defaults['wireguard_ip'], 
        '127.0.0.1', 
        '0.0.0.0'
      ]
    end

    def ti_client_id
      if ti_client.present?
        ti_client.id
      elsif card_terminal.present? &&
         card_terminal.connector.present? && 
         card_terminal.connector.ti_client.present?
        card_terminal.connector.ti_client.id
      else
        nil
      end
    end
  end
end
