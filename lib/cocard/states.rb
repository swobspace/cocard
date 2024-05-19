module Cocard
  module States
    #
    # Global states
    #
    NOTHING  = -1.freeze
    OK       = 0.freeze
    WARNING  = 1.freeze
    CRITICAL = 2.freeze
    UNKNOWN  = 3.freeze

    def self.flag(state)
      case state
      when UNKNOWN then "\u2753"
      when CRITICAL then "\u274C"
      when WARNING then "\u26A1"
      when OK then "\u2705"
      else
        ""
      end
    end
  end
end
