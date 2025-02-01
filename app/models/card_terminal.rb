class CardTerminal < ApplicationRecord
  include PingConcerns
  include CardTerminalConcerns
  include Cocard::Condition
  include NotableConcerns

  # -- associations
  has_many :logs, as: :loggable, dependent: :destroy
  has_many :terminal_workplaces, dependent: :destroy
  has_many :workplaces, through: :terminal_workplaces
  belongs_to :location, optional: true
  belongs_to :connector, optional: true
  belongs_to :network, optional: true
  has_many :cards, dependent: :destroy

  # -- configuration
  broadcasts_refreshes

  enum :pin_mode, { off: 0, on_demand: 1, auto: 2 }

  has_rich_text :description
  delegate :accessibility, to: :network, allow_nil: true

  # -- validations and callbacks
  before_save :update_ip_and_location
  before_save :ensure_displayname
  before_save :update_condition

  validates :pin_mode, inclusion: { in: pin_modes.keys }
  validates_uniqueness_of :ct_id, scope: [:connector_id],
                          allow_nil: true, allow_blank: true
  validates :mac, presence: {
                    message: "Entweder MAC oder Seriennummer müssen vorhanden sein"
                  },
                  unless: -> { serial.present? }
  validates_uniqueness_of :mac, allow_nil: true, case_sensitive: false
  validates :serial, presence: {
                    message: "Entweder MAC oder Seriennummer müssen vorhanden sein"
                  },
                  unless: -> { mac.present? }

  # -- common methods
  def to_s
    "#{name} - #{ct_id} (#{location&.lid})"
  end

  def mac
    self[:mac].gsub(/:/, '').upcase unless self[:mac].nil?
  end

  def rawmac
    self[:mac]
  end

  def product_information
    return nil if properties.blank?
    Cocard::ProductInformation.new(properties['product_information'])
  end

  def update_condition
    if connector.nil?
      return set_condition( Cocard::States::NOTHING,
                     "Kein Konnektor zugewiesen" )
    end
    if online?
      return set_condition( Cocard::States::OK,
                     "Kartenterminal online" )
    end
    if last_ok.blank?
      return set_condition( Cocard::States::NOTHING,
                     "Kartenterminal nicht in Betrieb" )
    end
    if is_accessible?
      is_up = up?
      if noip?
        return set_condition( Cocard::States::UNKNOWN,
                              "Kartenterminal hat keine sinnvolle IP: #{ip.to_s}" )
      elsif !is_up and !connected
        return set_condition( Cocard::States::CRITICAL,
                              "Kartenterminal nicht erreichbar, kein Ping und nicht mit dem Konnektor verbunden " )
      elsif !is_up and connected
        return set_condition( Cocard::States::WARNING,
                              "Kartenterminal mit dem Konnektor verbunden, aber Ping fehlgeschlagen" )
      elsif is_up and !connected
        return set_condition( Cocard::States::WARNING,
                              "Kartenterminal per Ping erreichbar, aber nicht mit dem Konnektor verbunden" )
      else
        return set_condition( Cocard::States::OK,
                              "Kartenterminal online - Ping nicht zuverlässig" )
      end
    else
      if !connected
        return set_condition( Cocard::States::CRITICAL,
                       "Kartenterminal nicht mit dem Konnektor verbunden" ) 
      else
        return set_condition( Cocard::States::UNKNOWN,
                   "Unbekannter Zustand, sollte nicht passieren" ) 
      end
    end
  end

  def is_accessible?
    !!(network&.ping?)
  end

  def online?
    if is_accessible?
      !!(up? && connected)
    else
      connected
    end
  end

  def update_ip_and_location
    if ip.nil? and current_ip.present?
      self[:ip] = current_ip
    end

    if will_save_change_to_ip?
      update_location_by_ip
    end
  end

private

  def ensure_displayname
    if displayname.blank? and name.present?
      self[:displayname] = name
    end
  end

end
