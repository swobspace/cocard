module CardTerminals
  class RMI       
    class OrgaV1::Info

      def initialize(properties)
        @properties = properties
      end

      def remote_pin_enabled
        properties['rmi_smcb_pinEnabled']
      end

      def remote_pairing_enabled
        properties['rmi_pairingEHealthTerminal_enabled']
      end

  private
      attr_reader :properties
    end
  end
end
