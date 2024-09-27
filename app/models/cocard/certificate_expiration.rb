module Cocard
  class CertificateExpiration

    ATTRIBUTES = %i( properties card_handle ct_id iccsn expiration_date )

    def initialize(hash)
      @hash = hash || {}
    end

    def properties
      hash
    end

    def ct_id
      hash[:ct_id]
    end

    def card_handle
      hash[:card_handle]
    end

    def iccsn
      hash[:iccsn]
    end

    def expiration_date
      hash[:validity]
    end

    def is_connector_cert
      card_handle.nil? && ct_id.nil?
    end

  private
    attr_reader :hash
  end
end
