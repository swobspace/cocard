module CardTerminals
  class RMI
    #
    # Null class for unknown and unsupported card_terminals
    #
    class Null < Base
      def call(*args)
        Result.new(success?: false, 
                   response: "CardTerminals::RMI::Null class doesn't support any actions")
      end
    end
  end
end

