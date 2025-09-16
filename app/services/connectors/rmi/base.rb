module Connectors
  class RMI
    #
    # Base class
    #
    class Base
      attr_reader :connector
      #
      # mandantory options:
      # * :connector - object
      #
      def initialize(options = {})
        options    = options.symbolize_keys
        @connector = options.fetch(:connector)
      end

      def available_actions
        []
      end

      def supported?
        false
      end

    end
  end
end

