module Cocard
  class NewKTProxy

    def initialize(options)
      @options  = options.symbolize_keys
      @card_terminal = options.fetch(:card_terminal)
      @defaults = options.fetch(:defaults) { Cocard.ktproxy_defaults }
    end

    def attributes
      {
        card_terminal_id: card_terminal.id,
        uuid: SecureRandom.uuid,
        name: card_terminal.displayname,
        wireguard_ip: defaults['wireguard_ip'],
        incoming_ip: defaults['incoming_ip'],
        incoming_port: '',
        outgoing_ip: defaults['outgoing_ip'],
        outgoing_port: '',
        card_terminal_ip: card_terminal.ip.to_s,
        card_terminal_port: defaults['card_terminal_port']
      }
    end

  private
    attr_reader :defaults, :options, :card_terminal
  end
end
