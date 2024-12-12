# frozen_string_literal: true

module TcpCheckConcerns
  extend ActiveSupport::Concern

  included do
  end

  def tcp_port_open?(port)
    begin
      Socket.tcp(ip.to_s, port, connect_timeout: 2) { true }
    rescue
      false
    end
  end
end
