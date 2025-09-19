module CardTerminals
  class RMI
    #
    # Remote Management Interface for Orga 6141 Version 1.03
    #
    class OrgaV1 < Base
      Result = Struct.new(:success?, :message, :value, keyword_init: true)

      def available_actions
        if firmware_version == '3.9.0'
          %i[ verify_pin get_idle_message set_idle_message get_info
              get_properties set_properties reboot ]
        elsif firmware_version >= '3.9.1'
          %i[ verify_pin get_idle_message set_idle_message get_info
              get_properties set_properties reboot remote_pairing ]
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
      def verify_pin(iccsn)
        EM.run {
          ws = Faye::WebSocket::Client.new(ws_url, [], {
                   ping: 15,
                   tls: {verify_peer: false}
                 }
               )

          ws.on :open do |event|
            debug(">>> :open verify pin >>>")
            ws.send(request.authenticate(generate_token(:authenticate),
                                         ws_auth_user, ws_auth_pass))
          end

          ws.on :message do |event|
            debug("--- :message verify pin ---")
            response = parse_ws_response(event.data)
            debug2(response)
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
              ws.send(request.get_property(generate_token(:get_property),
                                           ["rmi_smcb_pinEnabled"]))

            when :get_property
              if response.rmi_smcb_pin_enabled
                debug("rmi_smcb_pin_enabled: true")
                debug("--- starting timer ---")
                @timeout = EM::Timer.new(60) do
                  debug("### TIMEOUT ###")
                  @result['result'] = 'failure'
                  @result['failure'] = '### TIMEOUT ###'
                  ws.close
                end
                debug("--- send subscription ---")
                ws.send(request.subscribe_pin_verify(generate_token(:subscribe_pin), iccsn))
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

            when :subscribe_pin
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
              ws.send(request.verify_pin(generate_token(:verify_pin), iccsn, smcb_pin))

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
        if @result['result'] == 'failure'
          return Result.new(success?: false, message: @result['failure'])
        else
          return Result.new(success?: true, message: "PIN Verification complete")
        end
      end

      #
      # get_idle_message
      #
      def get_idle_message
        ret = get_properties(["gui_idleMessage"])
        if ret.success?
          ret.value = ret.value["gui_idleMessage"]
        end
        ret
      end

      def get_info
        ret = get_properties(%w[rmi_smcb_pinEnabled rmi_pairingEHealthTerminal_enabled])
        if ret.success?
          ret.value = Info.new(ret.value)
        end
        ret
      end

      def get_properties(properties)
        EM.run {
          ws = Faye::WebSocket::Client.new(ws_url, [], {
                   ping: 15,
                   tls: {verify_peer: false}
                 }
               )

          ws.on :open do |event|
            debug(">>> :open get properties >>>")
            ws.send(request.authenticate(generate_token(:authenticate),
                                         ws_auth_user, ws_auth_pass))
            debug("--- starting timer ---")
            @timeout = EM::Timer.new(20) do
              debug("### TIMEOUT ###")
              ws.close
              @result['result'] = 'failure'
              @result['failure'] = '### TIMEOUT ###'
            end
          end

          ws.on :message do |event|
            debug("--- :message get properties ---")
            response = parse_ws_response(event.data)
            debug2(response)
            unless response.success?
              @result['failure'] = response.json['failure']
              @result['result'] = 'failure'
              debug("--- :message - closing on failure ---")
              log_failure("Function: get_properties," +
                          " Action: #{session[response.token]}," +
                          " JSON: #{response.json.inspect}")
              ws.close
            end

            case session[response.token]
            when :authenticate
              ws.send(request.get_property(generate_token(:get_property),
                                           properties))

            when :get_property
              if response.properties.any?
                @timeout.cancel
                debug("properties: " + response.properties.inspect)
                @result['properties'] = response.properties
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
        if @result['result'] == 'success'
          Result.new(success?: true, message: "Get properties complete",
                     value: @result['properties'] )
        else
          Result.new(success?: false, message: @result['failure'])
        end
      end

      #
      # set_idle_message
      #
      def set_idle_message(idle_message)
        idle_message = clean_idle_message(idle_message)
        set_properties({ "gui_idleMessage" => idle_message })
      end

      def set_properties(properties)
        EM.run {
          ws = Faye::WebSocket::Client.new(ws_url, [], {
                   ping: 15,
                   tls: {verify_peer: false}
                 }
               )

          ws.on :open do |event|
            debug(">>> :open set properties >>>")
            ws.send(request.authenticate(generate_token(:authenticate),
                                         ws_auth_user, ws_auth_pass))
            debug("--- starting timer ---")
            @timeout = EM::Timer.new(20) do
              debug("### TIMEOUT ###")
              @result['result'] = 'failure'
              @result['failure'] = '### TIMEOUT ###'
              ws.close
            end
          end

          ws.on :message do |event|
            debug("--- :message set properties ---")
            response = parse_ws_response(event.data)
            debug2(response)
            unless response.success?
              @result['failure'] = response.json['failure']
              @result['result'] = 'failure'
              debug("--- :message - closing on failure ---")
              log_failure("Function: set_properties," +
                          " Action: #{session[response.token]}," +
                          " JSON: #{response.json.inspect}")
              ws.close
            end

            case session[response.token]
            when :authenticate
              ws.send(request.set_property(generate_token(:set_property), properties))

            when :set_property
              @timeout.cancel
              @result['result'] = (response.result.nil?) ? 'success' : 'failure'
              debug("set properties: " + @result['result'])
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
        if @result['result'] == 'success'
          return Result.new(success?: true, message: "Set properties complete")
        else
          return Result.new(success?: false, message: @result['failure'])
        end
      end

      #
      # reboot
      #
      def reboot
        EM.run {
          ws = Faye::WebSocket::Client.new(ws_url, [], {
                   ping: 15,
                   tls: {verify_peer: false}
                 }
               )

          ws.on :open do |event|
            debug(">>> :open reboot >>>")

            ws.send(request.authenticate(generate_token(:authenticate),
                                         ws_auth_user, ws_auth_pass))
          end

          ws.on :message do |event|
            debug("--- :message reboot ---")
            response = parse_ws_response(event.data)
            debug2(response)
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
              ws.send(request.reboot(generate_token(:reboot)))

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
        if @result['result'] == 'success'
          return Result.new(success?: true, message: "Reboot initiated")
        else
          return Result.new(success?: false, message: @result['failure'])
        end
      end

      #
      # remote pairing
      #
      def remote_pairing
        EM.run {
          ws = Faye::WebSocket::Client.new(ws_url, [], {
                   ping: 15,
                   tls: {verify_peer: false}
                 }
               )

          ws.on :open do |event|
            debug(">>> :open remote pairing >>>")
            ws.send(request.authenticate(generate_token(:authenticate),
                                         ws_auth_user, ws_auth_pass))
          end

          ws.on :message do |event|
            debug("--- :message remote pairing ---")
            response = parse_ws_response(event.data)
            debug2(response)
            unless response.success?
              @result['failure'] = response.json['failure']
              @result['result'] = 'failure'
              log_failure("Function: remote_pairing," +
                          " Action: #{session[response.token]}," +
                          " JSON: #{response.json.inspect}")
              ws.close
            end

            case session[response.token]
            when :authenticate
              ws.send(request.get_property(generate_token(:get_property),
                                           ["rmi_pairingEHealthTerminal_enabled"]))

            when :get_property
              if response.rmi_pairingEHealthTerminal_enabled
                debug("rmi_pairingEHealthTerminal_enabled: true")
                debug("--- starting timer ---")
                @timeout = EM::Timer.new(60) do
                  debug("### TIMEOUT ###")
                  @result['result'] = 'failure'
                  @result['failure'] = '### TIMEOUT ###'
                  ws.close
                end
                debug("--- send subscription ---")
                ws.send(request.subscribe_pairing(generate_token(:subscribe_pairing)))
              else
                debug("rmi_pairingEHealthTerminal_enabled: false -> enabling")
                ws.send(request.set_property(
                          generate_token(:set_property),
                          {"rmi_pairingEHealthTerminal_enabled" => true}
                       ))
              end

            when :set_property
              @result['result'] = (response.result.nil?) ? 'success' : 'failure'
              debug("set properties: " + @result['result'])
              @timeout = EM::Timer.new(60) do
                debug("### TIMEOUT ###")
                @result['result'] = 'failure'
                @result['failure'] = '### TIMEOUT ###'
                ws.close
              end
              ws.send(request.subscribe_pairing(generate_token(:subscribe_pairing)))

            when :subscribe_pairing
              subscription_uuid = response.result
              debug("Subscription UUID: " + subscription_uuid.to_s)
              session[:subscription_uuid] = subscription_uuid
              session[subscription_uuid] = :notification

            when :notification
              debug("Notification received: #{response.json}")
              debug("Dialog ID: #{response.dialog_id}")
              Turbo::StreamsChannel.broadcast_prepend_to(
                'verify_pins',
                target: 'toaster',
                partial: "shared/turbo_toast",
                locals: {
                  status: :info,
                  message: "Pairing-Anfrage vom Terminal erhalten, sende OK"
                }
              )
              ws.send(request.do_pairing(generate_token(:do_pairing), response.dialog_id))

            when :do_pairing
              @timeout.cancel
              debug("Do Pairing Response: #{response.json}")
              ws.close
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
        if @result['result'] == 'failure'
          return Result.new(success?: false, message: @result['failure'])
        else
          return Result.new(success?: true, message: "Pairing complete")
        end
      end

    private
      attr_reader :logger, :request

      def request
        @request ||= Request.new(session)
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

      def debug(message)
        logger.debug("CardTerminal(#{card_terminal.id})::RMI: #{message}")
      end

      def debug2(response)
        debug("Type: #{response.type}")
        debug("Token: #{response.token}")
        debug("Action: #{session[response.token]}")
        debug("SessionId: #{session['id']}")
        debug("JSON: #{response.json.inspect}")
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
