class Card < ApplicationRecord
  include CardConcerns
  include Cocard::Condition
  include NotableConcerns
  include SoftDeletion
  include Taggable

  # -- associations
  has_many :logs, as: :loggable, dependent: :destroy

  belongs_to :card_terminal_slot, optional: true
  has_one :card_terminal, through: :card_terminal_slot
  has_many :card_contexts, dependent: :destroy
  has_many :contexts, through: :card_contexts
  belongs_to :location, optional: true
  belongs_to :operational_state, optional: true

  # -- configuration
  broadcasts_refreshes

  has_rich_text :description
  has_rich_text :private_information

  accepts_nested_attributes_for :card_contexts,
    allow_destroy: true,
    reject_if: proc { |att| att['context_id'].blank? }

  delegate :slotid, to: :card_terminal_slot, allow_nil: true

  # -- validations and callbacks
  before_save :update_condition
  before_save :update_location
  before_save :update_acknowledge_id
  validates :iccsn, presence: true, uniqueness: { case_sensitive: false }

  # -- common methods
  def to_s
    if iccsn == card_holder_name
      "#{iccsn}"
    else
      "#{iccsn} - #{card_holder_name}"
    end
  end

  def update_condition
    # -- NOTHING
    if (!operational_state&.operational)
      msg = operational_state&.name || "Karte nicht in Betrieb"
      set_condition( Cocard::States::NOTHING, msg )
    elsif card_terminal_slot&.card_terminal_id.nil?
      set_condition( Cocard::States::NOTHING,
                     "Kein Kartenterminal zugewiesen - Karte nicht gesteckt? - UNUSED" )
    elsif expiration_date.nil?
      set_condition( Cocard::States::NOTHING,
                     "Kein Ablaufdatum - UNUSED" )
    elsif (card_type == 'SMC-B' and contexts.empty?)
      set_condition( Cocard::States::NOTHING,
                     "Kein Context konfiguriert" )

    # -- UNKNOWN
    elsif (card_type == 'SMC-B' and certificate.blank?)
      set_condition( Cocard::States::UNKNOWN,
                     "SMB-C: kein Zertifikat verfügbar, bitte Konfiguration überprüfen" )

    # -- CRITICAL
    elsif (expiration_date <= Date.current)
      set_condition( Cocard::States::CRITICAL,
                     "Gültigkeit der Karte abgelaufen!" )
    elsif (card_type == 'SMC-B' and pin_status == Cocard::States::CRITICAL)
      set_condition( Cocard::States::CRITICAL,
                     "PIN nicht verifiziert" )

    # -- WARNING
    elsif expiration_date <= 3.month.after(Date.current)
      set_condition( Cocard::States::WARNING,
                     "Gültigkeit der Karte läuft bald ab: #{expiration_date.to_s} (<= 3 month)" )

    # -- OK
    else
      set_condition( Cocard::States::OK, nil )
    end
  end

  def update_location
    if ['SMC-B', 'SMC-KT'].include?(card_type) and card_terminal&.location_id
      self[:location_id] = card_terminal&.location_id
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
