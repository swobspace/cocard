module CardTerminals
  class RMI
    #
    # Remote Management Interface for Orga 6141 Version 1.03
    #
    class OrgaV1 < Base
      def available_actions
        if firmware_version == '3.9.0'
          %i( verify_pin get_idle_message set_idle_message reboot )
        elsif firmware_version >= '3.9.1'
          %i( verify_pin get_idle_message set_idle_message reboot remote_pairing )
        else
          []
        end
      end

      def supported?
       if firmware_version >= '3.9.0'
         true
       else
         false
       end
      end

      #
      # verify_pin(iccsn)
      #
      # subscribe notifications for iccsn and wait max. 60 sec
      # for notifications.
      # send pin if requested until timeout
      #
      def verify_pin(params = {})
        params = params.symbolize_keys
        iccsn = params.fetch(:iccsn)
        EM.run {
          ws = Faye::WebSocket::Client.new(ws_url, [], {
                   ping: 15,
                   tls: {verify_peer: false}
                 }
               )

          ws.on :open do |event|
            debug(">>> :open verify pin >>>")

            ws.send(request_auth(generate_token(:authenticate)))
          end

          ws.on :message do |event|
            debug("--- :message verify pin ---")
            response = parse_ws_response(event.data)
            debug("Type: #{response.type}")
            debug("Token: #{response.token}")
            debug("Action: #{session[response.token]}")
            debug("SessionId: #{session['id']}")
            debug("JSON: #{response.json.inspect}")
            unless response.success?
              @result['failure'] = response.json['failure']
              @result['result'] = 'failure'
              log_failure("Function: verify_pin," +
                          " Action: #{session[response.token]}," + 
                          " JSON: #{response.json.inspect}")
              # don't close here, multiple PIN verify requests possible
              # !ws.close
            end

            case session[response.token]
            when :authenticate
              ws.send(request_get_property_pin_enabled(generate_token(:get_property)))

            when :get_property
              if response.rmi_smcb_pin_enabled
                debug("rmi_smcb_pin_enabled: true")
                debug("--- starting timer ---")
                @timeout = EM::Timer.new(60) do
                  debug("### TIMEOUT ###")
                  ws.close
                end
                debug("--- send subscription ---")
                ws.send(request_subscription(generate_token(:subscribe), iccsn))
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
              ws.send(request_verify_pin(generate_token(:verify_pin), iccsn))

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
            ws.close
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

      #
      # get_idle_message
      # 
      # fetch idle message from card terminal
      # and write result to @result['idle_message']
      #
      def get_idle_message(params = {})
        EM.run {
          ws = Faye::WebSocket::Client.new(ws_url, [], {
                   ping: 15,
                   tls: {verify_peer: false}
                 }
               )

          ws.on :open do |event|
            debug(">>> :open get idle >>>")

            ws.send(request_auth(generate_token(:authenticate)))
            debug("--- starting timer ---")
            @timeout = EM::Timer.new(20) do
              debug("### TIMEOUT ###")
              ws.close
              @result['result'] == timeout
            end
          end

          ws.on :message do |event|
            debug("--- :message get idle ---")
            response = parse_ws_response(event.data)
            debug("Type: #{response.type}")
            debug("Token: #{response.token}")
            debug("Action: #{session[response.token]}")
            debug("SessionId: #{session['id']}")
            debug("JSON: #{response.json.inspect}")
            unless response.success?
              @result['failure'] = response.json['failure']
              @result['result'] = 'failure'
              debug("--- :message - closing on failure ---")
              log_failure("Function: get_idle_message," +
                          " Action: #{session[response.token]}," + 
                          " JSON: #{response.json.inspect}")
              ws.close
            end

            case session[response.token]
            when :authenticate
              ws.send(request_get_property_idle_message(generate_token(:get_property)))

            when :get_property
              if response.gui_idle_message
                @timeout.cancel
                debug("gui_idle_message: " + response.gui_idle_message.to_s)
                @result['idle_message'] = response.gui_idle_message
                @result['result'] = 'success'
                ws.close
              end
            end
          end

          ws.on :error do |event|
            debug([:error, event.message])
            ws.close
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

      #
      # set_idle_message
      # 
      # set idle message on card terminal
      # and write result to @result['result']
      # success means @result['result'] = 'success'
      #
      def set_idle_message(params = {})
        params = params.symbolize_keys
        idle_message = params.fetch(:idle_message)
        idle_message = clean_idle_message(idle_message)
        EM.run {
          ws = Faye::WebSocket::Client.new(ws_url, [], {
                   ping: 15,
                   tls: {verify_peer: false}
                 }
               )

          ws.on :open do |event|
            debug(">>> :open set idle >>>")
            ws.send(request_auth(generate_token(:authenticate)))
            debug("--- starting timer ---")
            @timeout = EM::Timer.new(20) do
              debug("### TIMEOUT ###")
              @result['result'] == timeout
              ws.close
            end
          end

          ws.on :message do |event|
            debug("--- :message set idle ---")
            response = parse_ws_response(event.data)
            debug("Type: #{response.type}")
            debug("Token: #{response.token}")
            debug("Action: #{session[response.token]}")
            debug("SessionId: #{session['id']}")
            debug("JSON: #{response.json.inspect}")
            unless response.success?
              @result['failure'] = response.json['failure']
              @result['result'] = 'failure'
              debug("--- :message - closing on failure ---")
              log_failure("Function: set_idle_message," +
                          " Action: #{session[response.token]}," + 
                          " JSON: #{response.json.inspect}")
              ws.close
            end

            case session[response.token]
            when :authenticate
              ws.send(request_set_property_idle_message(generate_token(:set_property), idle_message))

            when :set_property
              @timeout.cancel
              @result['result'] = (response.result.nil?) ? 'success' : 'failure'
              debug("set gui_idle_message: " + @result['result'])
              ws.close
            end
          end

          ws.on :error do |event|
            debug([:error, event.message])
            ws.close
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

      #
      # reboot
      # 
      def reboot(params = {})
        EM.run {
          ws = Faye::WebSocket::Client.new(ws_url, [], {
                   ping: 15,
                   tls: {verify_peer: false}
                 }
               )

          ws.on :open do |event|
            debug(">>> :open get idle >>>")

            ws.send(request_auth(generate_token(:authenticate)))
          end

          ws.on :message do |event|
            debug("--- :message reboot ---")
            response = parse_ws_response(event.data)
            debug("Type: #{response.type}")
            debug("Token: #{response.token}")
            debug("Action: #{session[response.token]}")
            debug("SessionId: #{session['id']}")
            debug("JSON: #{response.json.inspect}")
            unless response.success?
              @result['failure'] = response.json['failure']
              @result['result'] = 'failure'
              debug("--- :message - closing on failure ---")
              log_failure("Function: reboot," +
                          " Action: #{session[response.token]}," + 
                          " JSON: #{response.json.inspect}")
              ws.close
            end

            case session[response.token]
            when :authenticate
              ws.send(request_reboot(generate_token(:reboot)))

            when :reboot
              debug("reboot done")
              @result['result'] = (response.result.nil?) ? 'success' : 'failure'
              if @result['result'] == 'success'
                card_terminal.update(rebooted_at: Time.current)
              end
              ws.close
            end
          end

          ws.on :error do |event|
            debug([:error, event.message])
            ws.close
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

      def request_get_property_pin_enabled(token)
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

      def request_get_property_idle_message(token)
        {
          "request" => {
            "token": token,
            "service": "Settings",
            "method": {
              "getProperties": {
                "sessionId": session['id'],
                "propertyIds": [
                  "gui_idleMessage"
                ]
              }
            }
          }
        }.to_json
      end

      def request_set_property_idle_message(token, idle_message)
        {
          "request" => {
            "token": token,
            "service": "Settings",
            "method": {
              "setProperties": {
                "sessionId": session['id'],
                "properties": {
                  "gui_idleMessage": "#{idle_message}"
                }
              }
            }
          }
        }.to_json
      end

      def request_subscription(token, iccsn)
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

      def request_verify_pin(token, iccsn)
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

      def request_reboot(token)
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


      def debug(message)
        logger.debug("CardTerminal(#{card_terminal.id})::RMI: #{message}")
      end
   
      def log_failure(message)
        Rails.logger.warn("WARN:: CardTerminal(#{card_terminal.id})::RMI: #{message}")
      end
   
      def clean_idle_message(msg)
        msg.gsub(/[^ 0-9A-Za-zÄÖÜäöüß!?#$&_\/*+.,;'-]/, '_')
      end

    end
  end
end
