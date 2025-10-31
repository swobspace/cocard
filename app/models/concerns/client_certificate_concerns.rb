module ClientCertificateConcerns
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where("expiration_date >= ?", Date.current) }
    scope :expired, -> { where("expiration_date < ?", Date.current) }
  end

  def to_text
    return unless cert.present?
    c = OpenSSL::X509::Certificate.new(cert)
    c.to_text
  end

end
