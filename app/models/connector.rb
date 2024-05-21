class Connector < ApplicationRecord
  include PingConcerns
  include ConnectorConcerns
  # -- associations
  has_and_belongs_to_many :locations
  has_many :card_terminals, dependent: :restrict_with_error
  has_many :connector_contexts, -> { order(position: :asc) }, dependent: :destroy
  has_many :contexts, through: :connector_contexts

  # -- configuration
  has_rich_text :description

  accepts_nested_attributes_for :connector_contexts,
    allow_destroy: true,
    reject_if: proc { |att| att['context_id'].blank? }

  # -- validations and callbacks
  before_save :ensure_update_condition
  before_save :ensure_sds_url
  before_save :ensure_admin_url
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
    shortcut = Cocard::States::flag(condition)
    case condition
      when Cocard::States::CRITICAL
        shortcut + " CRITICAL - Connector unreachable"
      when Cocard::States::UNKNOWN
        shortcut + " UNKNOWN - soap request failed, may be a configuration problem"
      when Cocard::States::WARNING
        shortcut + " WARNING - Connector reachable but TI offline!"
      when Cocard::States::OK
        shortcut + " OK - Connector TI online"
      when Cocard::States::NOTHING
        shortcut + " UNUSED - Configuration may not be complete yet"
    end
  end

private

  def ensure_update_condition
    if soap_request_success_changed? or vpnti_online_changed?
      update_condition
    end
    if condition_changed? and condition == Cocard::States::OK
      self[:last_check_ok] = Time.current
    end
  end

  def ensure_sds_url
    if sds_url.blank? and Cocard::sds_url.present?
      template = Liquid::Template.parse(Cocard::sds_url)
      self[:sds_url] = template.render('ip' => ip.to_s)
    end
  end

  def ensure_admin_url
    if admin_url.blank? and Cocard::admin_url.present?
      template = Liquid::Template.parse(Cocard::admin_url)
      self[:admin_url] = template.render('ip' => ip.to_s)
    end
  end

  def _name
    if name.blank?
      "-"
    else
      name
    end
  end
end
