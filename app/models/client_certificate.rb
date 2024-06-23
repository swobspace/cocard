class ClientCertificate < ApplicationRecord
  # -- associations
  has_and_belongs_to_many :connectors

  # -- configuration
  has_rich_text :description

  # -- validations and callbacks
  validates :name, :cert, :pkey, presence: true

  # -- common methods
  def to_s
    "#{name}"
  end

  def client
    cn
  end

  def cn
    from_subject("CN")
  end

  def certificate
    OpenSSL::X509::Certificate.new(cert)
  end

  def private_key
    OpenSSL::PKey.read(pkey, passphrase)
  end

  def valid_until
    return nil unless certificate.kind_of?(OpenSSL::X509::Certificate)
    certificate.not_after
  end

private

  def from_subject(attr)
    return nil unless certificate.kind_of?(OpenSSL::X509::Certificate)
    entry = certificate.subject.to_a.select{|a| a[0] == attr}.first
    ( entry.nil? ) ? "" : entry[1].force_encoding('UTF-8')
  end

end
