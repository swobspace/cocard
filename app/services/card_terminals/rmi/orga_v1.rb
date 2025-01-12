module CardTerminals
  module RMI
    #
    # Remote Management Interface for Orga 6141 Version 1.03
    #
    class OrgaV1
      attr_reader :card_terminal, :iccsn, :valid, :session

      #
      # rmi = CardTerminal::RMI::OrgaV1.new(options)
      #
      # mandantory options:
      # * :card_terminal - card_terminal object
      #
      def initialize(options = {})
        options.symbolize_keys
        @card_terminal = options.fetch(:card_terminal)
        @iccsn = options.fetch(:iccsn)
        @valid = check_terminal
        @session = {}
        @logger = ActiveSupport::Logger.new(File.join(Rails.root, 'log', 'card_terminals_rmi_orgav1.log'))
      end

      def verify_pin
        EM.run {
          ws = Faye::WebSocket::Client.new(ws_url, [], {
                   ping: 15,
                   tls: {verify_peer: false}
                 }
               )

          ws.on :open do |event|
            debug(">>> :open >>>")

            ws.send(request_auth(generate_token(:authenticate)))
          end

          ws.on :message do |event|
            debug("--- :message ---")
            response = parse_ws_response(event.data)
            debug("Type: #{response.type}")
            debug("Token: #{response.token}")
            debug("Action: #{session[response.token]}")
            debug("JSON: #{response.json.inspect}")
            debug("SessionId: #{session['id']}")

            case session[response.token]
            when :authenticate
              ws.send(request_get_property(generate_token(:get_property)))

            when :get_property
              if response.rmi_smcb_pin_enabled
                debug("rmi_smcb_pin_enabled: true")
                debug("--- starting timer ---")
                @timeout = EM::Timer.new(60) do
                  debug("### TIMEOUT ###")
                  ws.close
                end
                debug("--- send subscription ---")
                ws.send(request_subscription(generate_token(:subscribe)))
              else
                Turbo::StreamsChannel.broadcast_prepend_to(
                  'verify_pins',
                  target: 'toaster',
                  partial: "shared/turbo_toast",
                  locals: {
                    status: :warning,
                    message: "Remote SMC-B PIN ist am Terminal deaktiviert!"
                  }
                )
                debug("rmi_smcb_pin_enabled: false")
              end

            when :subscribe
              subscription_uuid = response.result
              debug("Subscription UUID: " + subscription_uuid.to_s)
              session[:subscription_uuid] = subscription_uuid
              session[subscription_uuid] = :notification

            when :notification
              debug("Notification received: #{response.json}")
              Turbo::StreamsChannel.broadcast_prepend_to(
                'verify_pins',
                target: 'toaster',
                partial: "shared/turbo_toast",
                locals: {
                  status: :info,
                  message: "PIN-Anfrage vom Terminal erhalten, sende SMC-B PIN ..."
                }
              )
              ws.send(request_verify_pin(generate_token(:verify_pin)))

            when :verify_pin
              # @timeout.cancel
              debug("Verify Pin Response: #{response.json}")
              # ws.close
            else
              # ws.close
            end
          end

          ws.on :error do |event|
            debug([:error, event.message])
          end

          ws.on :close do |event|
            debug("--- :close ---")
            debug([:close, event.code, event.reason])
            ws = nil
            EM.stop
            debug("<<< :closed <<<\n")
          end
        }
      end

    private
      attr_reader :logger

      def check_terminal
        card_terminal.pin_mode != 'off' &&
        card_terminal.product_information&.product_code == "ORGA6100" &&
        card_terminal.firmware_version >= '3.9.0'
      end

      def generate_token(action)
        token = SecureRandom.uuid
        session[token] = action
        token
      end

      def parse_ws_response(data)
        response = Response.new(data)
        if response.session_id.present?
          session['id'] = response.session_id
        end
        response
      end

      def ws_url
        url = "wss://#{card_terminal.ip}"
      end

      def ws_auth_user
        ENV['DEFAULT_WS_AUTH_USER']
      end

      def ws_auth_pass
        ENV['DEFAULT_WS_AUTH_PASS']
      end

      def smcb_pin
        ENV['DEFAULT_SMCB_PIN']
      end

      #
      # Request/Response constructs
      #

      def request_auth(token)
        {
          "request" => {
            "token": token,
            "service": "Auth",
            "method": {
              "basicAuth": {
                "user": ws_auth_user,
                "credentials": ws_auth_pass
              }
            }
          }
        }.to_json
      end

      def request_get_property(token)
        {
          "request" => {
            "token": token,
            "service": "Settings",
            "method": {
              "getProperties": {
                "sessionId": session['id'],
                "propertyIds": [
                  "rmi_smcb_pinEnabled"
                ]
              }
            }
          }
        }.to_json
      end

      def request_subscription(token)
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

      def request_verify_pin(token)
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


      def debug(message)
        logger.debug("CardTerminal(#{card_terminal.id})::RMI: #{message}")
      end

    end
  end
end
