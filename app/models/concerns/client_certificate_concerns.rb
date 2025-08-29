module ClientCertificateConcerns
  extend ActiveSupport::Concern

  included do
  end

  def to_text
    return unless cert.present?
    c = OpenSSL::X509::Certificate.new(cert)
    c.to_text
  end

end
