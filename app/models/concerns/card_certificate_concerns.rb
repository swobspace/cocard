module CardCertificateConcerns
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where("card_certificates.expiration_date >= ?", Date.current) }
    scope :expired, -> { where("card_certificates.expiration_date < ?", Date.current) }
  end

  def to_text
    return unless certificate.present?
    c = OpenSSL::X509::Certificate.new(Base64.decode64(certificate))
    c.to_text
  end

end
