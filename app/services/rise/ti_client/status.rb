module RISE
  module TIClient
    class Status
      def self.success(*args) new(:success, *args) end
      def self.unsupported() new(:unsupported) end
      def self.failure(error) new(:failure, error) end

      attr_reader :message, :value

      def initialize(status, message = nil, value = nil)
        @status  = status
        @message = message
        @value   = value
      end

      def on_success
        yield(message, value) if @status == :success
      end

      def on_unsupported
        yield if @status == :unsupported
      end

      def on_failure
        yield(message) if @status == :failure
      end

    end
  end
end
