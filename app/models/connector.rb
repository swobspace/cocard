class Connector < ApplicationRecord
  include PingConcerns
  # -- associations
  has_and_belongs_to_many :locations
  has_many :connector_contexts
  has_many :contexts, through: :connector_contexts

  # -- configuration
  has_rich_text :description

  # -- validations and callbacks
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

private
  def _name
    if name.blank?
      "-"
    else
      name
    end
  end
end
