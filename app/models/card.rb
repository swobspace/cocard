class Card < ApplicationRecord
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
    case condition
      when Cocard::States::CRITICAL
        "CRITICAL - Certificate expired; PIN not verified(SMC-B only)"
      when Cocard::States::UNKNOWN
        "UNKNOWN - old data; certificate not read (SMC-B only)"
      when Cocard::States::WARNING 
        "WARNING - Certificate expires in less than 3 month"
      when Cocard::States::OK
        "OK - Certificate valid (>= 3 month); PIN verified (SMC-B only)"
      when Cocard::States::NOTHING
        "UNUSED - Missing connector or no context assigned (SMC-B only)"
    end
  end
  
  def update_condition
    if card_terminal&.connector.nil?
      self[:condition] = Cocard::States::NOTHING
    elsif expiration_date.nil?
      self[:condition] = Cocard::States::NOTHING
    elsif card_type == 'SMC-B' and context.nil?
      self[:condition] = Cocard::States::NOTHING
    elsif expiration_date <= Date.current
      self[:condition] = Cocard::States::CRITICAL
    elsif card_type == 'SMC-B' and pin_status != 'VERIFIED'
      self[:condition] = Cocard::States::CRITICAL
    elsif expiration_date <= 3.month.after(Date.current)
      self[:condition] = Cocard::States::WARNING
    elsif card_type == 'SMC-B' and certificate.blank?
      self[:condition] = Cocard::States::UNKNOWN
    elsif updated_at <= 2.days.before(Time.current)
      self[:condition] = Cocard::States::UNKNOWN
    elsif
      self[:condition] = Cocard::States::OK
    else
    end
  end

private


  def ensure_update_condition
    if pin_status_changed? or expiration_date_changed?
      update_condition
    end
  end

end
