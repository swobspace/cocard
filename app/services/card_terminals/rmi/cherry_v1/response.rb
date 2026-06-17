module CardTerminals
  class RMI
    #
    # JSON response parser for Cherry ST-1506 remote management and remote SMC-B APIs.
    #
    class CherryV1::Response
      attr_reader :data, :json

      def initialize(data)
        @data = data
        @json = JSON.parse(data)
      end

      def management?
        json.key?('header') || json.key?(:header)
      end

      def smcb?
        json.key?('Header') || json.key?(:Header)
      end

      def payload_type
        json['payloadType'] || json[:payloadType] || json['PayloadType'] || json[:PayloadType]
      end

      def msg_id
        header['msgId'] || header[:msgId] || header['MsgId'] || header[:MsgId]
      end

      def in_reply_to_id
        header['inReplyToId'] || header[:inReplyToId] || header['InReplyToId'] || header[:InReplyToId]
      end

      def session_id
        payload['sessionId'] || payload[:sessionId] ||
          payload['SessionId'] || payload[:SessionId] ||
          header['SessionId'] || header[:SessionId]
      end

      def error
        payload['error'] || payload[:error]
      end

      def success?
        error.blank? && notify_code_success?
      end

      def key
        payload['key'] || payload[:key]
      end

      def challenge
        payload['Challenge'] || payload[:Challenge]
      end

      def input_pin_request?
        payload_type == 'InputPinRequest'
      end

      def output_request?
        payload_type == 'OutputRequest'
      end

      def authenticate_request?
        payload_type == 'AuthenticateRequest'
      end

      def notify?
        payload_type == 'Notify'
      end

      def cancel?
        payload_type == 'Cancel'
      end

      def notify_code
        payload['Code'] || payload[:Code]
      end

      def slot
        payload['Slot'] || payload[:Slot] || payload['slot'] || payload[:slot]
      end

      def expect_response?
        payload['ExpectResponse'] || payload[:ExpectResponse]
      end

      def ok_button?
        payload['OkButton'] || payload[:OkButton]
      end

      def message
        payload['Message'] || payload[:Message]
      end

      def message_type
        payload['MessageType'] || payload[:MessageType]
      end

    private
      def header
        json['header'] || json[:header] || json['Header'] || json[:Header] || {}
      end

      def payload
        json['payload'] || json[:payload] || json['Payload'] || json[:Payload] || {}
      end

      def notify_code_success?
        !notify? || notify_code == 0 || notify_code == '0'
      end
    end
  end
end
