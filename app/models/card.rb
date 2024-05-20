class Card < ApplicationRecord
  include CardConcerns
  # -- associations
  belongs_to :card_terminal, optional: true
  belongs_to :context, optional: true
  belongs_to :location, optional: true
  belongs_to :operational_state, optional: true

  # -- configuration
  has_rich_text :description

  # -- validations and callbacks
  before_save :ensure_update_condition
  validates :iccsn, presence: true, uniqueness: { case_sensitive: false }

  # -- common methods
  def to_s
    "#{iccsn} - #{card_holder_name}"
  end


  def condition_message
    shortcut = Cocard::States::flag(condition)
    case condition
      when Cocard::States::CRITICAL
        if expiration_date.blank? 
          shortcut + " CRITICAL - ???"
        elsif expiration_date < Date.current
          shortcut + " CRITICAL - Certificate expired"
        else
          shortcut + " CRITICAL - PIN not verified (SMC-B only)"
        end
      when Cocard::States::UNKNOWN
        shortcut + " UNKNOWN - card not found or certificate not read (SMC-B only)"
      when Cocard::States::WARNING 
        shortcut + " WARNING - Certificate expires in less than 3 month"
      when Cocard::States::OK
        shortcut + " OK - Certificate valid (>= 3 month); PIN verified (SMC-B only)"
      when Cocard::States::NOTHING
        shortcut + " UNUSED - Missing connector or no context assigned (SMC-B only)"
    end
  end
  
  def update_condition
    if !operational_state&.operational or
       card_terminal&.connector.nil? or
       expiration_date.nil? or
       (card_type == 'SMC-B' and context.nil?)
      self[:condition] = Cocard::States::NOTHING

    elsif (expiration_date <= Date.current) or
          (card_type == 'SMC-B' and pin_status != 'VERIFIED')
      self[:condition] = Cocard::States::CRITICAL

    elsif expiration_date <= 3.month.after(Date.current)
      self[:condition] = Cocard::States::WARNING

    elsif (card_type == 'SMC-B' and certificate.blank?)
      self[:condition] = Cocard::States::UNKNOWN

    elsif
      self[:condition] = Cocard::States::OK
    else
    end
  end

private


  def ensure_update_condition
    if pin_status_changed? or expiration_date_changed? or card_handle_changed?
      update_condition
    end
  end

end
