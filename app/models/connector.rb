class Connector < ApplicationRecord
  # -- associations
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :clients

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


private
  def _name
    if name.blank?
      "-"
    else
      name
    end
  end
end
