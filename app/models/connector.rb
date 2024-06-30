class Connector < ApplicationRecord
  include PingConcerns
  include ConnectorConcerns
  include Cocard::Condition

  # -- associations
  has_many :logs, as: :loggable, dependent: :destroy
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :client_certificates
  has_many :card_terminals, dependent: :restrict_with_error
  has_many :connector_contexts, -> { order(position: :asc) }, dependent: :destroy
  has_many :contexts, through: :connector_contexts

  # -- configuration
  has_rich_text :description

  enum authentication: { noauth: 0, clientcert: 1 }

  accepts_nested_attributes_for :connector_contexts,
    allow_destroy: true,
    reject_if: proc { |att| att['context_id'].blank? }


  # -- validations and callbacks
  before_save :ensure_update_condition
  before_save :ensure_sds_url
  before_save :ensure_admin_url
  validates :ip, presence: true, uniqueness: true
  validates :authentication, inclusion: { in: authentications.keys }

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
      set_condition(Cocard::States::CRITICAL, 
                    "Connector unreachable, ping failed")
    else 
      if !soap_request_success
        set_condition(Cocard::States::UNKNOWN, 
                      "soap request failed, may be a configuration problem")
      elsif !vpnti_online
        set_condition(Cocard::States::CRITICAL,
                      "Connector reachable but TI offline!")
      else
        set_condition(Cocard::States::OK,
                      "Connector TI online")
      end
    end
  end

private

  def ensure_update_condition
    if !condition_changed? and (soap_request_success_changed? or vpnti_online_changed?)
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
