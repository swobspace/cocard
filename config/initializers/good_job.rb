# config/initializers/good_job.rb
$stdout.sync = true

Rails.application.configure do
  config.good_job = {
    execution_mode: :external,
    enable_cron: true,
    max_threads: 4,
    poll_interval: 30,
    retry_on_unhandled_error: false,
    preserve_job_records: true,
    # cleanup_interval_jobs: 100,
    cleanup_interval_seconds: 3600,

    cron: {
      fetch_sds: {
        cron: '0 4 * * *',
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
      get_cards: {
        cron: '*/7 * * * *',
        class: "Cocard::GetCardsJob",
        description: "Get cards from connector; SMC-B only: check PIN status"
      }
    }
  }
end
