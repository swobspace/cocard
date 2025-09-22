class Connectors::RebootJob < ApplicationJob
  queue_as :default

  def perform(options = {})
    options.symbolize_keys!
    connector = options.fetch(:connector) { Connector.where(manual_update: false,
                                                            boot_mode: :cron).to_a }
    if connector.is_a? Array
      connector.each do |conn|
        # create one job for each connector
        Connectors::RebootJob.perform_later(connector: conn)
      end
    else
      # single connector
      if !connector.rebootable?
        Rails.logger.warn("WARN:: reboot connector #{connector.name} via cron not supported")
      elsif connector.boot_mode != 'cron'
        Rails.logger.warn("WARN:: reboot connector #{connector.name} not enabled")
      else
        connector.rmi.reboot do |result|
          result.on_success do |message|
            msg = message
            Rails.logger.debug("DEBUG:: reboot connector #{connector.name} via cron: #{msg}")
            if Cocard.auto_reboot_connectors_note
              msg = "Via Cron: #{msg}"
              Note.create!(notable: connector, user: myadmin, message: msg)
            end
          end

          result.on_failure do |message|
            msg = "Reboot fehlgeschlagen: " + message
            Rails.logger.warn("WARN:: reboot connector #{connector.name} via cron failed: #{msg}")
          end

          result.on_unsupported do |result|
            Rails.logger.warn("WARN:: reboot connector #{connector.name} not supported")
          end
        end
      end
    end
  end

  def myadmin
    Wobauth::User.where(username: 'admin').first || Wobauth::User.first
  end

end
