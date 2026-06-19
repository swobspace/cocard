module CardTerminals
  class RMI
    #
    # JSON request builder for Cherry ST-1506 remote management and remote SMC-B APIs.
    #
    class CherryV1::Request
      def initialize(session)
        @session = session
      end

      def login(username, password)
        management_request('LoginRequest', username: username, password: password)
      end

      def logout
        management_request('LogoutRequest', {})
      end

      def smcb_authentication
        management_request('SmcbAuthenticationRequest', {})
      end

      def authenticate_response(request_msg_id, response)
        smcb_response('AuthenticateResponse', request_msg_id, Response: response)
      end

      def output_response(request_msg_id, code)
        smcb_response('OutputResponse', request_msg_id, Code: code)
      end

      def input_pin_response(request_msg_id, pin)
        smcb_response('InputPinResponse', request_msg_id, Code: 'Pin', Pin: pin)
      end

    private
      attr_reader :session

      def management_request(payload_type, payload)
        message = {
          header: {
            msgId: generate_msg_id
          },
          payloadType: payload_type,
          payload: payload
        }
        message[:header][:sessionId] = session[:management_session_id] if session[:management_session_id].present?
        message.to_json
      end

      def smcb_response(payload_type, in_reply_to_id, payload)
        message = {
          Header: {
            MsgId: generate_msg_id,
            InReplyToId: in_reply_to_id
          },
          PayloadType: payload_type,
          Payload: payload
        }
        message[:Header][:SessionId] = session[:smcb_session_id] if session[:smcb_session_id].present?
        message.to_json
      end

      def generate_msg_id
        SecureRandom.hex(16)
      end
    end
  end
end
