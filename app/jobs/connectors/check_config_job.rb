class Connectors::CheckConfigJob < ApplicationJob
  queue_as :default

  #
  # Check Connector Configuration and broadcast a toast if problem found
  # Connectors::CheckConfigJob.perform_later(connector: connector)
  #
  def perform(options = {})
    options.symbolize_keys!
    connector = options.fetch(:connector)
    status = nil

    # check only if connector reachable
    return false unless connector.up?

    # SDS port
    unless connector.tcp_port_open?(connector.sds_port)
      text = "Port #{connector.sds_port} für SDS nicht erreichbar, bitte SDS_URL prüfen!"
      toaster(connector, :warning, text)
    end

    # SOAP port
    unless connector.tcp_port_open?(connector.soap_port)
      text = "Port #{connector.soap_port} für SOAP nicht erreichbar, bitte TLS-Einstellungen prüfen!"
      toaster(connector, :warning, text)
    end
  end

private
  def toaster(connector, status, message)
    unless status.nil?
      Turbo::StreamsChannel.broadcast_prepend_to(
        connector,
        target: 'toaster',
        partial: "shared/turbo_toast",
        locals: {status: status, message: message})
    end
  end
end
