module Connectors
  class RMI
    #
    # Base class
    #
    class Base
      Result = ImmutableStruct.new(:success?, :response)

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

      def call(*args)
        raise RuntimeError, "Connectors::RMI::Base class called, don't use it directly!"
      end

    end
  end
end

