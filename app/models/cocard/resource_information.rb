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

    def vpnti_online
      !!(vpnti_connection_status == "Online")
    end

    def operating_state
      connector[:operating_state] || {}
    end

    def error_states
      @error_states ||= [].tap do |es|
        errs = (operating_state[:error_state].nil?) ? [] : operating_state[:error_state]
        errs.each do |e|
          es << Cocard::ErrorState.new(e)
        end
      end
    end

  private
    attr_reader :hash
  end

end
