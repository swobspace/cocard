module Cocard
  class CardCertificate
    attr_reader :crypt

    ATTRIBUTES = %i( cert_ref issuer serial_number subject_name certificate
                     expiration_date crypt)

    def initialize(card_cert_hash, crypt)
      if card_cert_hash.has_key?(:cert_ref) and card_cert_hash.has_key?(:x509_data)
        @hash = card_cert_hash 
        @crypt = crypt
      else
        raise "Missing card cert hash"
      end
    end

    def cert_ref
      hash.fetch(:cert_ref)
    end

    def issuer
      hash.dig(:x509_data, :x509_issuer_serial, :x509_issuer_name)
    end

    def serial_number
      hash.dig(:x509_data, :x509_issuer_serial, :x509_serial_number)
    end

    def subject_name
      hash.dig(:x509_data, :x509_subject_name)
    end

    def x509_certificate
      hash.dig(:x509_data, :x509_certificate)
    end

    def cocard_cert
      @certificate ||= Cocard::Certificate.new(x509_certificate)
    end
   
    def certificate
      x509_certificate.to_s
    end

    def openssl_cert
      cocard_cert.cert
    end


    def expiration_date
      openssl_cert.not_after.to_date.to_s
    end

    def save(card:)
      ::CardCertificate.find_or_create_by!(card_id: card.id,
                                           cert_ref: cert_ref, crypt: crypt ) do |cc|
          ATTRIBUTES.each do |attr|
            next if [:card_id, :cert_ref, :crypt].include?(attr)
            cc.send("#{attr}=", self.send(attr))
          end
      end
    end

  private
    attr_reader :hash

  end
end
