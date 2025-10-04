class Connector < ApplicationRecord
  include PingConcerns
  include TcpCheckConcerns
  include ConnectorConcerns
  include Cocard::Condition
  include NotableConcerns
  include Taggable

  # -- associations
  has_one :ti_client, dependent: :restrict_with_error
  has_many :logs, as: :loggable, dependent: :destroy
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :client_certificates
  has_many :card_terminals, dependent: :restrict_with_error
  has_many :connector_contexts, -> { order(position: :asc) }, dependent: :destroy
  has_many :contexts, through: :connector_contexts

  # -- configuration
  broadcasts_refreshes
  has_rich_text :description

  enum :authentication, { noauth: 0, clientcert: 1, basicauth: 2 }
  enum :boot_mode, { off: 0, cron: 1 }

  accepts_nested_attributes_for :connector_contexts,
    allow_destroy: true,
    reject_if: proc { |att| att['context_id'].blank? }


  # -- validations and callbacks
  before_save :update_condition
  before_save :ensure_sds_url
  before_save :ensure_admin_url
  before_save :update_acknowledge_id
  validates :ip, presence: true, uniqueness: true
  validates :short_name, uniqueness: { case_insensitive: true, allow_blank: true }
  validates :authentication, inclusion: { in: authentications.keys }

  # -- common methods
  def to_s
    "#{_name} / #{ip}"
  end

  def name
    if self[:name].blank?
      "#{ip}"
    else
      self[:name]
    end
  end

  def product_information
    if connector_services.nil?
      Cocard::ProductInformation.new(nil)
    else
      Cocard::ProductInformation.new(connector_services['ProductInformation'])
    end
  end

  def service_information
    return [] if connector_services.nil?
    connector_services['ServiceInformation']['Service'].map do |svc|
      Cocard::Service.new(svc)
    end
  end

  def identification
    "#{product_information&.product_vendor_id}-#{product_information&.product_code}"
  end

  def service(svcname)
    service_information.select{|x| x.name == svcname }.first
  end

  def update_condition
    if manual_update
      set_condition(Cocard::States::NOTHING,
                    "Manuelles Update aktiviert")
    elsif reboot_active? or
          (rebooted? and (!up? or !soap_request_success or !vpnti_online))
      set_condition(Cocard::States::WARNING,
                    "Reboot um #{rebooted_at.localtime.to_s}, stay tuned...")
    elsif !up?
      set_condition(Cocard::States::CRITICAL,
                    "Konnektor nicht erreichbar, Ping fehlgeschlagen")
    elsif !soap_request_success
      set_condition(Cocard::States::UNKNOWN,
                    "SOAP-Abfrage fehlgeschlagen, Konfigurationsproblem, Port nicht erreichbar oder Konnektor funktioniert nicht richtig")
    elsif !vpnti_online
      set_condition(Cocard::States::CRITICAL,
                    "Konnektor erreichbar (Ping), aber TI offline!")
    # elsif expiration_date.present? and (expiration_date <= 3.month.after(Date.current))
    #   set_condition( Cocard::States::WARNING,
    #                  "Das Zertifikat des Konnektors läuft bald ab: #{expiration_date.to_s} (<= 3 month)" )
    else
      set_condition(Cocard::States::OK,
                    "Konnektor online")
      self[:rebooted_at] = nil
    end
  end

private

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
    if self[:name].blank?
      "-"
    else
      name
    end
  end

end
