class CardTerminal < ApplicationRecord
  include PingConcerns
  include CardTerminalConcerns
  include Cocard::Condition

  # -- associations
  has_many :logs, as: :loggable, dependent: :destroy
  has_many :terminal_workplaces, dependent: :destroy
  has_many :workplaces, through: :terminal_workplaces
  belongs_to :location, optional: true
  belongs_to :connector, optional: true
  has_many :cards, dependent: :destroy

  # -- configuration
  has_rich_text :description

  # -- validations and callbacks
  before_save :ensure_displayname
  before_save :ensure_update_condition
  validates_uniqueness_of :ct_id, scope: [:connector_id],
                          allow_nil: true, allow_blank: true
  validates :mac, presence: {
                    message: "Entweder MAC oder Seriennummer müssen vorhanden sein"
                  },
                  unless: -> { serial.present? }
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
      set_condition( Cocard::States::NOTHING,
                     "No connector assigned" )

    elsif !up?
      set_condition( Cocard::States::CRITICAL,
                     "CardTerminal unreachable - ping failed" ) 
    elsif !connected
      set_condition( Cocard::States::WARNING,
                     "CardTerminal reachable, but not connected" )
    else
      set_condition( Cocard::States::OK,
                     "CardTerminal online" )
    end
  end

private

  def ensure_displayname
    if displayname.blank? and name.present?
      self[:displayname] = name
    end
  end

  def ensure_update_condition
    if connected_changed?
      update_condition
    end
  end

end
