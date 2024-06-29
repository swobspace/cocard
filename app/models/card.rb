class Card < ApplicationRecord
  include CardConcerns
  include Cocard::Condition

  # -- associations
  has_many :logs, as: :loggable, dependent: :destroy
  belongs_to :card_terminal, optional: true
  belongs_to :context, optional: true
  belongs_to :location, optional: true
  belongs_to :operational_state, optional: true

  # -- configuration
  has_rich_text :description
  has_rich_text :private_information

  # -- validations and callbacks
  before_save :ensure_update_condition
  validates :iccsn, presence: true, uniqueness: { case_sensitive: false }

  # -- common methods
  def to_s
    "#{iccsn} - #{card_holder_name}"
  end

  def update_condition
    # -- NOTHING
    if card_terminal&.connector.nil?
      set_condition( Cocard::States::NOTHING,
                     "Missing CardTerminal - UNUSED" )
    elsif expiration_date.nil?
      set_condition( Cocard::States::NOTHING,
                     "Missing expiration_date - UNUSED" )
    elsif (card_type == 'SMC-B' and !operational_state&.operational)
      set_condition( Cocard::States::NOTHING,
                     "Nicht in Betrieb" )
    elsif (card_type == 'SMC-B' and context.nil?)
      set_condition( Cocard::States::NOTHING,
                     "Missing Context" )

    # -- CRITICAL
    elsif (expiration_date <= Date.current)
      set_condition( Cocard::States::CRITICAL,
                     "Card expired!" )
    elsif (card_type == 'SMC-B' and pin_status != 'VERIFIED')
      set_condition( Cocard::States::CRITICAL,
                     "PIN not verified" )

    # -- WARNING
    elsif expiration_date <= 3.month.after(Date.current)
      set_condition( Cocard::States::WARNING,
                     "Card expires at #{expiration_date.to_s} (<= 3 month)" )

    # -- UNKNOWN
    elsif (card_type == 'SMC-B' and certificate.blank?)
      set_condition( Cocard::States::UNKNOWN,
                     "SMB-C: no certificate available, please check configuration" )

    # -- OK
    else
      set_condition( Cocard::States::OK, nil )
    end
  end

private


  def ensure_update_condition
    if pin_status_changed? or expiration_date_changed? or card_handle_changed?
      update_condition
    end
  end

end
