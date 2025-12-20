# config/initializers/good_job.rb
$stdout.sync = true

Rails.application.configure do
  config.good_job = {
    execution_mode: :external,
    enable_cron: true,
    max_threads: 12,
    poll_interval: 30,
    retry_on_unhandled_error: false,
    preserve_job_records: true,
    # cleanup_interval_jobs: 100,
    cleanup_interval_seconds: 3600,
    cleanup_preserved_jobs_before_seconds_ago: 172800,
    cron: {
      fetch_sds: {
        cron: '30 23 * * *',
        class: "ConnectorServices::FetchJob",
        description: "Fetch current SDS info from all connectors"
      },
      get_connectors: {
        cron: '*/3 * * * *',
        class: "Cocard::GetResourceInformationJob",
        description: "Get resource information from connector"
      },
      get_card_terminals: {
        cron: '*/5 * * * *',
        class: "Cocard::GetCardTerminalsJob",
        description: "Get card terminals from connector"
      },
      get_card_terminal_info: {
        cron: '55 03 * * *',
        class: "CardTerminals::RMI::GetInfoJob",
        description: "Fetch card terminal infos via RMI"
      },
      ti_lagebild: {
        cron: '*/5 * * * *',
        class: "TI::GetSituationPictureJob",
        description: "Get card terminals from connector",
        set: { wait: 1.minute }
      },
      get_cards: {
        cron: '*/7 * * * *',
        class: "Cocard::GetCardsJob",
        description: "Get cards from connector; SMC-B only: check PIN status"
      },
      verify_all_pins: {
        cron: '*/5 * * * *',
        class: "Cards::VerifyAllPinsJob",
        description: "Verify PINs of all cards if neccessary"
      },
      check_certificate_expiration: {
        cron: '55 23 * * *',
        class: "Cocard::CheckCertificateExpirationJob",
        description: "Get SMC-K certificate expiration from connector"
      },
      cleanup_expired_acknowledges: {
        cron: '30 05 * * *',
        class: "CleanupExpiredAcknowledgesJob",
        description: "Cleanup expired acknowledges"
      },
      check_for_outdated: {
        cron: '31 04 * * *',
        class: "OutdatedJob",
        description: "Check for outdated Cards/CardTerminals"
      },
      reboot_connectors: {
        cron: Cocard.cron_reboot_connectors,
        class: "Connectors::RebootJob",
        description: "Automatic reboot connectors"
      },
    }
  }
end
