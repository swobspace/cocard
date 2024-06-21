class CardTerminal < ApplicationRecord
  include PingConcerns
  include CardTerminalConcerns
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
  validates :mac, presence: true


  # -- common methods
  def to_s
    "#{name} - #{ct_id} (#{location&.lid})"
  end

  def mac
    self[:mac].gsub(/:/, '').upcase unless self[:mac].nil?
  end

  def product_information
    return nil if properties.blank?
    Cocard::ProductInformation.new(properties['product_information'])
  end

  def condition_message
    shortcut = Cocard::States::flag(condition)
    case condition
      when Cocard::States::CRITICAL
        shortcut + " CRITICAL - CardTerminal unreachable"
      when Cocard::States::UNKNOWN
        shortcut + " UNKNOWN - not yet implemented"
      when Cocard::States::WARNING
        shortcut + " WARNING - CardTerminal not connected"
      when Cocard::States::OK
        shortcut + " OK - CardTerminal online"
      when Cocard::States::NOTHING
        shortcut + " UNUSED - Configuration may not be complete yet"
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
