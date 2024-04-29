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

    cron: {
      fetch_sds: {
        cron: '0 4 * * *',
        class: "ConnectorServices::FetchJob",
        description: "Fetch current SDS info from all connectors"
      },
      get_resource_information: {
        cron: '*/5 * * * *',
        class: "Cocard::GetResourceInformationJob",
        description: "Get resource information from connector"
      }
    }
  }
end
