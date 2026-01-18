class CardCertificate < ApplicationRecord
  # -- associations
  belongs_to :card

  # -- configuration
  REF_TYPES = %w[ C.AUT C.ENC C.SIG C.QES ]
  # -- validations and callbacks
  validates :card_id, :crypt, presence: true
  validates :cert_ref, presence: true, 
                       uniqueness: { case_sensitive: true, scope: [:card_id, :crypt] },
                       inclusion:  { in: REF_TYPES }

  # -- common methods
  def to_s
    "#{subject_name} (#{cert_ref})"
  end

end
