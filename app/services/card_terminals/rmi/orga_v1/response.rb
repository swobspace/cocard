module CardTerminals
  module RMI       
    class OrgaV1::Response
      attr_reader :data, :json
      #
      # parse messages from websocket
      #
      # mandantory options:
      # * :data - string from message in json format

      def initialize(data)
        @data = data
        @json = JSON.parse(data)
      end

      def token
        json.dig('response', 'token')
      end

      def session_id
        json.dig('response', 'result', 'session', 'id')
      end

      def rmi_smcb_pin_enabled
        json.dig('response', 'result', 'properties', 'rmi_smcb_pinEnabled') || false
      end

    end
  end
end
