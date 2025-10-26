module KTProxyConcerns
  extend ActiveSupport::Concern

  included do
  end

  def to_builder
    Jbuilder.new do |kt|
      kt.set! 'id', uuid
      kt.set! 'name', name
      kt.set! 'wireguardIp', wireguard_ip
      kt.set! 'incomingIp', incoming_ip
      kt.set! 'incomingPort', incoming_port
      kt.set! 'outgoingIp', outgoing_ip
      kt.set! 'outgoingPort', outgoing_port
      kt.set! 'cardTerminalIp', card_terminal_ip
      kt.set! 'cardTerminalPort', card_terminal_port
    end
  end

end
