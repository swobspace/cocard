module RISE
  module TIClient
    class Status
      def self.success(*args) new(:success, *args) end
      def self.unsupported() new(:unsupported) end
      def self.access_denied(error) new(:access_denied, error) end
      def self.failure(error) new(:failure, error) end
      def self.notfound(*args) new(:notfound, *args) end

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

      def on_notfound
        yield(message) if @status == :notfound
      end

      def on_failure
        yield(message) if @status == :failure
      end

      def on_access_denied
        yield(message) if @status == :access_denied
      end

    end
  end
end
