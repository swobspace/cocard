module Cocard
  class PinStatus

    ATTRIBUTES = %i( pin_status left_tries )

    def initialize(hash)
      @hash = hash || {}
    end

    def pin_status
      hash[:pin_status]
    end

    def to_s
      pin_status
    end

    def left_tries
      hash[:left_tries]
    end
  private
    attr_reader :hash
  end
end
