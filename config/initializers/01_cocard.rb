module Cocard
  CONFIGFILE = File.join(Rails.root, 'config', 'cocard.yml')
  config = YAML.load_file(CONFIGFILE) if File.readable? CONFIGFILE
  CONFIG = config || {}

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

  def self.fetch_config(attribute, default_value)
    CONFIG[attribute.to_s].presence || default_value
  end

  def self.cron_reboot_connectors
    if Fugit.parse_cron(ENV['CRON_REBOOT_CONNECTORS'])
      ENV['CRON_REBOOT_CONNECTORS']
    else
      '5 1 * * 1'
    end
  end

  def self.auto_reboot_connectors_note
    if ENV['AUTO_REBOOT_CONNECTORS_NOTE'] == 'yes'
      true
    else
      false
    end
  end

  def self.ldap_options
    if CONFIG['ldap_options'].present?
      ldapopts = CONFIG['ldap_options']
      ldapopts = [ldapopts] if ldapopts.is_a? Hash
      ldapopts.each do |opts|
        opts.symbolize_keys!
        opts.each do |k, _v|
          opts[k] = opts[k].symbolize_keys if opts[k].is_a? Hash
        end
      end
    end
  end

  def self.enable_ldap_authentication
    return false unless self.ldap_options.present?
    fetch_config('enable_ldap_authentication', false)
  end

  def self.enable_ticlient
    fetch_config('enable_ticlient', false)
  end

  def self.ktproxy_defaults
    Hash(fetch_config('ktproxy_defaults', {}))
  end

  def self.ktproxy_equal_ports
    fetch_config('ktproxy_equal_ports', false)
  end

  def self.ntp_server
    fetch_config('ntp_server', nil)
  end

  def self.ntp_enabled
    fetch_config('ntp_enabled', true)
  end

  def self.tftp_server
    fetch_config('tftp_server', nil)
  end

  def self.tftp_file
    fetch_config('tftp_file', nil)
  end

  Rails.application.routes.default_url_options = {
    host: (ENV['URL_HOST'] || 'localhost'),
    port: (ENV['URL_PORT'] || '3000'),
    protocol: (ENV['URL_PROTOCOL'] || 'http'),
  }

end
