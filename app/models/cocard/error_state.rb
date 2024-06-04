module Cocard
  class ErrorState
    def initialize(hash)
      @hash = hash || {}
    end

    def error_condition
      hash[:error_condition]
    end

    def severity
      hash[:severity]
    end

    def type
      hash[:type]
    end

    def value
      hash[:value]
    end

    def valid_from
      hash[:valid_from]
    end

    def valid?
      value
    end

  private
    attr_reader :hash
  end
end

