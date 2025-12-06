class Connectors::HealthCheckJob < ApplicationJob
  queue_as :default
  LDAPS_PORT = 636

  def perform(options = {})
    options.symbolize_keys!
    connector = options.fetch(:connector)
    @user     = options.fetch(:user)
    status = nil

    if connector.up?
      toaster(connector, :info, "Konnektor PING ok")
    else
      toaster(connector, :danger, "Konnektor PING failed")
      return false
    end


    # SDS port
    if connector.tcp_port_open?(connector.sds_port)
      text = "SDS-Port #{connector.sds_port} ok"
      toaster(connector, :info, text)
    else
      text = "Port #{connector.sds_port} für SDS nicht erreichbar, bitte SDS_URL und Konnektor prüfen!"
      toaster(connector, :warning, text)
    end

    # SOAP port
    if connector.tcp_port_open?(connector.soap_port)
      text = "SOAP-Port #{connector.soap_port} ok"
      toaster(connector, :info, text)
    else
      text = "Port #{connector.soap_port} für SOAP nicht erreichbar, bitte TLS-Einstellungen und Konnektor prüfen!"
      toaster(connector, :warning, text)
    end

    # LDAP SSL
    if connector.tcp_port_open?(LDAPS_PORT)
      text = "LDAP-Port #{LDAPS_PORT} ok"
      toaster(connector, :info, text)
    else
      text = "Port #{LDAPS_PORT} für LDAP nicht erreichbar!"
      toaster(connector, :warning, text)
    end
  end

private
  def toaster(connector, status, message)
    if connector.short_name.blank?
      message = "#{connector.name}: #{message}"
    else
      message = "#{connector.short_name}: #{message}"
    end
    unless status.nil?
      Turbo::StreamsChannel.broadcast_prepend_to(
        @user,
        target: 'toaster',
        partial: "shared/turbo_toast",
        locals: {status: status, message: message})
    end
  end
end
