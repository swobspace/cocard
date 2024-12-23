module Connectors
  class RMI
    #
    # Null class for unknown and unsupported connectors
    #
    class Null < Base
      def call(*args)
        Result.new(success?: false, 
                   response: "Connectors::RMI::Null class doesn't support any actions")
      end
    end
  end
end

