class CardTerminal < ApplicationRecord
  include PingConcerns
  include CardTerminalConcerns
  # -- associations
  belongs_to :location, optional: true
  belongs_to :connector, optional: true
  has_many :cards, dependent: :destroy

  # -- configuration
  has_rich_text :description

  # -- validations and callbacks
  before_save :ensure_displayname
  before_save :ensure_update_condition
  validates_uniqueness_of :ct_id, scope: [:connector_id]
  validates :mac, presence: true


  # -- common methods
  def to_s
    "#{name} - #{ct_id} (#{location&.lid})"
  end

  def product_information
    return nil if properties.blank?
    Cocard::ProductInformation.new(properties['product_information'])
  end

  def condition_message
    case condition
      when Cocard::States::CRITICAL
        "CRITICAL - CardTerminal unreachable"
      when Cocard::States::UNKNOWN
        "UNKNOWN - not yet implemented"
      when Cocard::States::WARNING
        "WARNING - CardTerminal not connected"
      when Cocard::States::OK
        "OK - CardTerminal online"
      when Cocard::States::NOTHING
        "UNUSED - Configuration may not be complete yet"
    end
  end

  def update_condition
    if connector.nil?
      self[:condition] = Cocard::States::NOTHING
    elsif !up?
      self[:condition] = Cocard::States::CRITICAL
    elsif !connected
        self[:condition] = Cocard::States::WARNING
    else
      self[:condition] = Cocard::States::OK
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
