module Cocard
  class PinVerify

    ATTRIBUTES = %i( pin_result status error_text left_tries )

    def initialize(hash)
      @hash = hash || {}
    end

    def pin_result
      hash[:pin_result]
    end

    def to_s
      pin_result
    end

    def status
      hash.dig(:status, :result)
    end

    def error_text
      hash.dig(:status, :error, :trace, :error_text)
    end

    def left_tries
      hash[:left_tries]
    end

  private
    attr_reader :hash
  end
end
