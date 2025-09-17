module CardTerminals
  class RMI       
    #
    # generate json requests
    #
    class OrgaV1::Request
      #
      # parse messages from websocket
      #
      # mandantory options:
      # * :session

      def initialize(session)
        @session = session
      end

      def authenticate(token, user, passwd)
        {
          "request" => {
            "token": token,
            "service": "Auth",
            "method": {
              "basicAuth": {
                "user": user,
                "credentials": passwd
              }
            }
          }
        }.to_json
      end

      def get_property(token, properties)
        {
          "request" => {
            "token": token,
            "service": "Settings",
            "method": {
              "getProperties": {
                "sessionId": session['id'],
                "propertyIds": Array(properties)
              }
            }
          }
        }.to_json
      end

      def set_property(token, properties)
        {
          "request" => {
            "token": token,
            "service": "Settings",
            "method": {
              "setProperties": {
                "sessionId": session['id'],
                "properties": Hash(properties)
              }
            }
          }
        }.to_json
      end

      def subscribe_pin_verify(token, iccsn)
        {
          "subscription" => {
            "token": token,
            "service": "Smartcard",
            "topic": {
              "pinVerificationTopic": {
                "sessionId": session['id'],
                "iccsn": iccsn
              }
            }
          }
        }.to_json
      end

      def verify_pin(token, iccsn)
        {
          "request" => {
            "token": token,
            "service": "Smartcard",
            "method": {
              "verifyPin": {
                "sessionId": session['id'],
                "iccsn": iccsn,
                "pinId": "SMCB-PIN",
                "pin": smcb_pin
              }
            }
          }
        }.to_json
      end

      def reboot(token)
        {
          "request" => {
            "token": token,
            "service": "System",
            "method": {
              "reboot": {
                "sessionId": session['id']
              }
            }
          }
        }.to_json
      end

  private
      attr_reader :session
    end
  end
end
