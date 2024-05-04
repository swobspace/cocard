module Cocard
  class Card

    ATTRIBUTES = %i( properties card_handle card_type iccsn ct_id slot_id 
                     insert_time card_holder_name certificate_expiration_date )

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

    def card_type
      hash[:card_type]
    end

    def iccsn
      hash[:iccsn]
    end

    def slot_id
      hash[:slot_id]&.to_i
    end

    def insert_time
      hash[:insert_time]
    end

    def card_holder_name
      hash[:card_holder_name]
    end

    def certificate_expiration_date
      hash[:certificate_expiration_date]
    end


  private
    attr_reader :hash
  end
end
