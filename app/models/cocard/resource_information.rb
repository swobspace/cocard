module Cocard
  class ResourceInformation
    def initialize(hash)
      @hash = hash || {}
    end

    def connector
      hash[:connector] || {}
    end

    def vpnti_status
      connector[:vpnti_status] || {}
    end

    def vpnti_connection_status
      vpnti_status[:connection_status]
    end

    def vpnti_connection_timestamp
      vpnti_status[:timestamp]
    end

    def vpnti_connection_condition
      
    end

  private
    attr_reader :hash
  end
end
