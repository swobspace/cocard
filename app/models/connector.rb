class Connector < ApplicationRecord
  include PingConcerns
  # -- associations
  has_and_belongs_to_many :locations
  has_many :connector_contexts
  has_many :contexts, through: :connector_contexts

  # -- configuration
  has_rich_text :description


  # -- validations and callbacks
  before_save :ensure_update_condition
  before_save :ensure_sds_url
  validates :ip, presence: true, uniqueness: true

  # -- common methods
  def to_s
    "#{_name} / #{ip}"
  end

  def product_information
    return nil if connector_services.nil?
    Cocard::ProductInformation.new(connector_services['ProductInformation'])
  end

  def service_information
    return [] if connector_services.nil?
    connector_services['ServiceInformation']['Service'].map do |svc|
      Cocard::Service.new(svc)
    end
  end

  def service(svcname)
    service_information.select{|x| x.name == svcname }.first
  end

  def update_condition
    unless up?
      self[:condition] = Cocard::States::CRITICAL
    else 
      if !soap_request_success
        self[:condition] = Cocard::States::UNKNOWN
      elsif !vpnti_online
        self[:condition] = Cocard::States::WARNING
      else
        self[:condition] = Cocard::States::OK
      end
    end
  end

  def condition_message
    case condition
      when Cocard::States::CRITICAL
        "CRITICAL - Connector unreachable"
      when Cocard::States::UNKNOWN
        "UNKNOWN - soap request failed, may be a configuration problem"
      when Cocard::States::WARNING
        "WARNING - Connector reachable but TI offline!"
      when Cocard::States::OK
        "OK - Connector TI online"
    end
  end

  def ensure_update_condition
    if soap_request_success_changed? or vpnti_online_changed?
      update_condition
    end
    if condition_changed? and condition == Cocard::States::OK
      self[:last_check_ok] = Time.current
    end
  end

  def ensure_sds_url
    if sds_url.blank?
      self[:sds_url] = "http://#{ip.to_s}/connector.sds"
    end
  end

private
  def _name
    if name.blank?
      "-"
    else
      name
    end
  end
end
