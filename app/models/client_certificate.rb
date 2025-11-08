class ClientCertificate < ApplicationRecord
  include ClientCertificateConcerns
  include Taggable

  # -- associations
  has_and_belongs_to_many :connectors

  # -- configuration
  has_rich_text :description

  # -- validations and callbacks
  validates :name, :cert, :pkey, presence: true
  validate :must_be_valid_cert_and_pkey
  before_save :update_client_system
  before_save :update_expiration_date

  # -- common methods
  def to_s
    "#{name} (#{valid_until.to_date.to_s})"
  end

  def cn
    from_subject("CN")
  end

  def certificate
    begin
      OpenSSL::X509::Certificate.new(cert)
    rescue
      nil
    end
  end

  def private_key
    begin
      OpenSSL::PKey.read(pkey, passphrase)
    rescue
      nil
    end
  end

  def valid_until
    return nil unless certificate.kind_of?(OpenSSL::X509::Certificate)
    certificate.not_after
  end

  def expired?
    expiration_date < Date.current
  end

  def self.p12_to_params(p12, exportpass)
    pkcs12 = OpenSSL::PKCS12.new(p12, exportpass)
    cert = pkcs12.certificate.to_pem
    unsecure_key = pkcs12.key
    cipher = OpenSSL::Cipher.new 'aes-256-cbc'
    passphrase = SecureRandom.base64(42)
    pkey = unsecure_key.private_to_pem cipher, passphrase
    { cert: cert, pkey: pkey, passphrase: passphrase }
  end

private

  def from_subject(attr)
    return nil unless certificate.kind_of?(OpenSSL::X509::Certificate)
    entry = certificate.subject.to_a.select{|a| a[0] == attr}.first
    ( entry.nil? ) ? "" : entry[1].force_encoding('UTF-8')
  end

  def update_client_system
    self[:client_system] = cn
  end

  def update_expiration_date
    self[:expiration_date] = valid_until
  end

  def must_be_valid_cert_and_pkey
    errors.add(:cert, 'Kein Zertifikat (PEM)') unless certificate.present?
    errors.add(:pkey, 'Kein Private Key (PEM) oder falsche Passphase') unless private_key.present?
  end


end
