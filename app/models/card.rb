class Card < ApplicationRecord
  include CardConcerns
  include Cocard::Condition
  include NotableConcerns

  # -- associations
  has_many :logs, as: :loggable, dependent: :destroy

  belongs_to :card_terminal, optional: true
  has_many :card_contexts, dependent: :destroy
  has_many :contexts, through: :card_contexts
  belongs_to :location, optional: true
  belongs_to :operational_state, optional: true

  # -- configuration
  # broadcasts_refreshes

  has_rich_text :description
  has_rich_text :private_information

  accepts_nested_attributes_for :card_contexts,
    allow_destroy: true,
    reject_if: proc { |att| att['context_id'].blank? }

  # -- validations and callbacks
  before_save :update_condition
  validates :iccsn, presence: true, uniqueness: { case_sensitive: false }

  # -- common methods
  def to_s
    "#{iccsn} - #{card_holder_name}"
  end

  def update_condition
    # -- NOTHING
    if (!operational_state&.operational)
      set_condition( Cocard::States::NOTHING,
                     "Karte nicht in Betrieb" )
    elsif card_terminal&.connector.nil?
      set_condition( Cocard::States::NOTHING,
                     "CardTerminal fehlt - UNUSED" )
    elsif expiration_date.nil?
      set_condition( Cocard::States::NOTHING,
                     "Kein Ablaufdatum - UNUSED" )
    elsif (card_type == 'SMC-B' and contexts.empty?)
      set_condition( Cocard::States::NOTHING,
                     "Kein Context konfiguriert" )

    # -- UNKNOWN
    elsif (card_type == 'SMC-B' and certificate.blank?)
      set_condition( Cocard::States::UNKNOWN,
                     "SMB-C: no certificate available, please check configuration" )

    # -- CRITICAL
    elsif (expiration_date <= Date.current)
      set_condition( Cocard::States::CRITICAL,
                     "Card expired!" )
    elsif (card_type == 'SMC-B' and pin_status == Cocard::States::CRITICAL)
      set_condition( Cocard::States::CRITICAL,
                     "PIN not verified" )

    # -- WARNING
    elsif expiration_date <= 3.month.after(Date.current)
      set_condition( Cocard::States::WARNING,
                     "Card expires at #{expiration_date.to_s} (<= 3 month)" )

    # -- OK
    else
      set_condition( Cocard::States::OK, nil )
    end
  end

  def pin_status(ctx_id = nil)
    if ctx_id.present?
      pinstatus = card_contexts.where(context_id: ctx_id).first.pin_status
      ( pinstatus == 'VERIFIED' ) ? Cocard::States::OK : Cocard::States::CRITICAL
    elsif card_contexts.empty?
      Cocard::States::WARNING
    elsif card_contexts.where("pin_status <> ?", 'VERIFIED').any?
      Cocard::States::CRITICAL
    else
      Cocard::States::OK
    end
  end

private

end
