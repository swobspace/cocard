module CardTerminals
  class RMI
    class Status
      def self.success(message) new(:success, message) end
      def self.unsupported() new(:unsupported) end
      def self.failure(error) new(:failure, error) end

      attr_reader :error

      def initialize(status, error = nil)
        @status = status
        @error  = error
      end

      def on_success
        yield if @status == :success
      end

      def on_unsupported
        yield if @status == :unsupported
      end

      def on_failure
        yield(error) if @status == :failure
      end

    end
  end
end
