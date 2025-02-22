module Cocard
  CONFIGURATION_CONTROLLER = [
    'locations',
    'networks',
    'workplaces',
    'contexts',
    'operational_states',
    'client_certificates',
  ].freeze

  EventServiceVersion = "7.2.0".freeze
  CertificateServiceVersion = "6.0.1".freeze
  CardServiceVersion = "8.1.2".freeze

  #
  # preparing for later external configuration
  # hardcoded at this stage
  #

  def self.grace_period
    15.minutes
  end

  def self.admin_url
    "https://{{ ip }}:9443"
  end

  def self.sds_url
    "http://{{ ip }}/connector.sds"
  end

  def self.ct_idle_message_template
    tmpl = <<-EOTMPL
    {%- if has_smcb? -%}
      {{ connector_short_name }} {{ name | slice: -6, 6 }}
    {%- else -%}
      {{ mac | slice: -6, 6 }}
    {%- endif -%}
EOTMPL
  end

  Rails.application.routes.default_url_options = {
    host: (ENV['URL_HOST'] || 'localhost'),
    port: (ENV['URL_PORT'] || '3000'),
    protocol: (ENV['URL_PROTOCOL'] || 'http'),
  }

end
