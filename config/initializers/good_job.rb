# config/initializers/good_job.rb
$stdout.sync = true

Rails.application.configure do
  config.good_job = {
    execution_mode: :external,
    enable_cron: true,
    max_threads: 4,
    poll_interval: 30,
    retry_on_unhandled_error: false,
    preserve_job_records: false,

    cron: {
      fetch_sds: {
        cron: 'every day',
        class: "ConnectorServices::FetchJob",
        description: "Fetch current SDS info from all connectors"
      }
    }
  }
end
