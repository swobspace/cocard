module KTProxyConcerns
  extend ActiveSupport::Concern

  included do
  end

  def to_builder
    Jbuilder.new do |j|
      j.set! 'id', uuid
      j.set! 'name', name
      j.set! 'wireguardIp', wireguard_ip
      j.set! 'incomingIp', incoming_ip
      j.set! 'incomingPort', incoming_port
      j.set! 'outgoingIp', outgoing_ip
      j.set! 'outgoingPort', outgoing_port
      j.set! 'cardTerminalIp', card_terminal_ip
      j.set! 'cardTerminalPort', card_terminal_port
    end
  end

end
