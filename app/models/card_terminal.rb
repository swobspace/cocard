class CardTerminal < ApplicationRecord
  include PingConcerns
  # -- associations
  belongs_to :location, optional: true
  belongs_to :connector

  # -- configuration
  has_rich_text :description

  # -- validations and callbacks
  before_save :ensure_displayname
  validates_uniqueness_of :mac, allow_blank: true


  # -- common methods
  def to_s
    "#{name} (#{location&.lid})"
  end

  def product_information
    return nil if properties.blank?
    Cocard::ProductInformation.new(properties[:product_information])
  end

  def ensure_displayname
    if displayname.blank? and name.present?
      self[:displayname] = name
    end
  end

end
