class DuckTerminal
  include PingConcerns
  include TcpCheckConcerns

  attr_reader :firmware_version, :identification, :ip, :rmi_port

  def initialize(options = {})
    options = options.to_hash.symbolize_keys
    @identification = options.fetch(:identification) {''}
    @firmware_version = options.fetch(:firmware_version) {''}
    @rmi_port = options.fetch(:rmi_port) { 443 }
    @ip = options.fetch(:ip) {''}
  end

  def id
    @id ||= SecureRandom.uuid
  end
end
