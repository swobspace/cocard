module KTProxyConcerns
  extend ActiveSupport::Concern

  included do
  end

  def to_builder
    Jbuilder.new do |kt|
      kt.set! 'id', uuid
      kt.set! 'name', name
      kt.set! 'wireguardIp', wireguard_ip.to_s
      kt.set! 'incomingIp', incoming_ip.to_s
      kt.set! 'incomingPort', incoming_port.to_s
      kt.set! 'outgoingIp', outgoing_ip.to_s
      kt.set! 'outgoingPort', outgoing_port.to_s
      kt.set! 'cardTerminalIp', card_terminal_ip.to_s
      kt.set! 'cardTerminalPort', card_terminal_port.to_s
    end
  end

end
