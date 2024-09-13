module CardTerminals
  module RMI
    #
    # Remote Management Interface for Orga 6141 Version 1.03
    #
    class OrgaV1
      attr_reader :card_terminal, :valid, :session

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

      def call
        EM.run {
          ws = Faye::WebSocket::Client.new(ws_url, [], {
                   ping: 15,
                   tls: {verify_peer: false}
                 }
               )

          ws.on :open do |event|
            debug([:open])

            token = generate_token(:authenticate)
            debug(request_auth(token))
            ws.send(request_auth(token))
          end

          ws.on :message do |event|
            debug([:message])
            (token, data) = parse_ws_response(event.data)
            debug("Token: " + token)
            debug("Action: " + session[token].to_s)
            debug("Data: " + data.inspect)
            debug("SessionId: " + session['id'].to_s)

            case session[token]
            when :authenticate
              ws.send(request_get_property(generate_token(:get_property)))
            when :get_property
              rmi_smcb_pin_enabled = data.dig('response', 'result', 'properties', 'rmi_smcb_pinEnabled')
              if rmi_smcb_pin_enabled
                debug("rmi_smcb_pin_enabled: true")
                ws.send(request_subscription(generate_token(:subscribe)))
              else
                debug("rmi_smcb_pin_enabled: false")
              end
              ws.close
            when :subscribe
              subscription_uuid = data.dig('response', 'result')
              debug("Subscription UUID: " + subscription_uuid.to_s)
              session[:subscription_uuid] = subscription_uuid
            when :notification
            else
              ws.close
            end
          end

          ws.on :error do |event|
            debug([:error, event.message])
          end

          ws.on :close do |event|
            debug([:close, event.code, event.reason])
            ws = nil
            EM.stop
          end
        }
      end

    private
      attr_reader :logger

      def check_terminal
        card_terminal.product_information&.product_code == "ORGA6100" &&
        card_terminal.firmware_version >= '3.9.0'
      end

      def generate_token(action)
        token = SecureRandom.uuid
        session[token] = action
        token
      end

      def parse_ws_response(data)
        json = JSON.parse(data)
        if json['response'].present?
          token = json.dig('response', 'token')
          if (session[token] == :authenticate)
            session['id'] = json.dig('response', 'result', 'session', 'id')
          end
        elsif json['notification'].present?
        else
        end
        [token, json]
      end

      def ws_url
        url = "wss://#{card_terminal.ip}"
      end

      def ws_auth_user
        ENV['WS_AUTH_USER']
      end

      def ws_auth_pass
        ENV['WS_AUTH_PASS']
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
          "request" => {
            "token": token,
            "service": "Smartcard",
            "method": {
              "pinVerificationTopic": {
                "sessionId": session['id'],
                "propertyIds": iccsn
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
