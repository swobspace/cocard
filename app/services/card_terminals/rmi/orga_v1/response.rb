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
        if type == 'notification'
          json.dig('notification', 'subscriptionId')
        else
          json.dig('response', 'token')
        end
      end

      def session_id
        if result.kind_of? String
          nil
        else
          json.dig('response', 'result', 'session', 'id')
        end
      end

      def rmi_smcb_pin_enabled
        if result.kind_of? String
          nil
        else
          json.dig('response', 'result', 'properties', 'rmi_smcb_pinEnabled') || false
        end
      end

      def gui_idle_message
        if result.kind_of? String
          nil
        else
          json.dig('response', 'result', 'properties', 'gui_idleMessage') || false
        end
      end

      def result
        json.dig('response', 'result')
      end

      def type
        json.keys.first
      end

      def success?
        type != 'failure'
      end

    end
  end
end
