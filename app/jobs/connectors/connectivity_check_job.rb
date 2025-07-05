class Connectors::ConnectivityCheckJob < ApplicationJob
  queue_as :default

  #
  # Check Connector connectivity and broadcast a toast if problem found
  # Connectors::ConnectivityCheckJob.perform_later(connector: connector)
  #
  def perform(options = {})
    options.symbolize_keys!
    connector = options.fetch(:connector)
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
        :connector_check,
        target: 'toaster',
        partial: "shared/turbo_toast",
        locals: {status: status, message: message})
    end
  end
end
