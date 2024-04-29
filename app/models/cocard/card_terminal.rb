module Cocard
  class CardTerminal
    def initialize(hash)
      @hash = hash || {}
    end

    def product_information
      ProductInformation.new(hash[:product_information])
    end

    def ct_id
      hash[:ct_id]
    end

    def workplace_ids
      hash[:workplace_ids] || {}
    end

    def workplaces
      workplace_ids[:workplace_id] || []
    end

    def name
      hash[:name]
    end

    def mac
      hash[:mac_address]
    end

    def ip_address
      hash[:ip_address] || {}
    end

    def ip
      ip_address[:ipv4_address]
    end

    def ct_id
      hash[:ct_id]
    end

    def slots
      hash[:slots]&.to_i
    end

    def is_physical
      hash[:is_physical]
    end

    def connected
      hash[:connected]
    end

  private
    attr_reader :hash
  end
end
