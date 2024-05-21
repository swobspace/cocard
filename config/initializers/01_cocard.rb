module Cocard
  CONFIGURATION_CONTROLLER = [
    'locations',
    'clients',
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
end
