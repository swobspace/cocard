module Cocard
  class CardCertificate

    ATTRIBUTES = %i( cert_ref issuer serial_number subject_name certificate
                     expiration_date )

    def initialize(card_cert_hash)
      if card_cert_hash.has_key?(:cert_ref) and card_cert_hash.has_key?(:x509_data)
        @hash = card_cert_hash 
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
      hash.dig(:x509_data, :x509_serial_number)
    end

    def x509_certificate
      hash.dig(:x509_data, :x509_certificate)
    end

    def cocard_cert
      @certificate ||= Cocard::Certificate.new(x509_certificate)
    end
   
    def certificate
      cocard_cert.cert
    end

    def expiration_date
      certificate.not_after.to_date.to_s
    end

  private
    attr_reader :hash

  end
end
