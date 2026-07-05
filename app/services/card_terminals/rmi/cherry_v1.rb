require 'openssl'

module CardTerminals
  class RMI
    #
    # Remote Management Interface for Cherry ST-1506.
    #
    # The ST-1506 exposes two websocket protocols on port 443:
    # * cobra      - remote management API, used to login and request an ephemeral SMC-B key
    # * cobra-smcb - remote SMC-B API, used to answer PIN prompts from the terminal
    #
    class CherryV1 < Base
      Result = Struct.new(:success?, :message, :value, keyword_init: true)
      AdvisoryLockUnavailable = Class.new(StandardError)

      # Cherry ST-1506 RMI uses EventMachine's process-global reactor. Serialize
      # each EM.run/EM.stop flow inside this Ruby process, while serializing the
      # full PIN verification only per terminal across workers/containers. The
      # process-local terminal mutex map is only a fallback for non-PostgreSQL/test
      # contexts. This intentionally does not affect ORGA.
      EM_REACTOR_MUTEX = Mutex.new
      TERMINAL_MUTEXES = {}
      TERMINAL_MUTEXES_MUTEX = Mutex.new
      VERIFY_PIN_LOCK_CLASS_ID = 20_240_617

      def available_actions
        return [] unless supported?

        %i[ verify_pin verify_pin_while get_info ]
      end

      def supported?
        true
      end

      def coordinated_verify_pin_supported?
        true
      end

      def rmi_port
        configured_rmi_port.presence || super
      end

      def verify_pin(iccsn)
        self.class.with_verify_pin_lock(card_terminal.id) { verify_pin_without_lock(iccsn) }
      end

      def verify_pin_while(iccsn, &block)
        unless block_given?
          return Result.new(success?: false, message: 'Block is required for ST-1506 PIN verification')
        end

        self.class.with_verify_pin_lock(card_terminal.id) { verify_pin_while_without_lock(iccsn, &block) }
      end

      def get_info
        unless rmi_port_reachable?
          return Result.new(success?: false, message: "RMI-Port #{rmi_port} unreachable!")
        end

        if ws_auth_pass.blank?
          return Result.new(success?: false, message: 'DEFAULT_WS_AUTH_PASS is not configured!')
        end

        fetch_device_information
      end

      def verify_pin_without_lock(iccsn)
        preflight = verify_pin_preflight(iccsn)
        return preflight unless preflight.success?

        connect_remote_smcb_api(preflight.value[:key], preflight.value[:slot_id])
      end
      private :verify_pin_without_lock

      def verify_pin_while_without_lock(iccsn, &block)
        preflight = verify_pin_preflight(iccsn)
        return preflight unless preflight.success?

        connect_remote_smcb_api_while(preflight.value[:key], preflight.value[:slot_id], &block)
      end
      private :verify_pin_while_without_lock

      def self.with_verify_pin_lock(terminal_id)
        body_started = false

        if postgresql_advisory_lock_available?
          with_postgresql_advisory_lock(terminal_id) do
            body_started = true
            yield
          end
        else
          with_terminal_mutex(terminal_id) { yield }
        end
      rescue AdvisoryLockUnavailable, ActiveRecord::ActiveRecordError, ActiveRecord::ConnectionNotEstablished, ActiveRecord::NoDatabaseError
        raise if body_started

        with_terminal_mutex(terminal_id) { yield }
      end

      def self.with_eventmachine_lock(&block)
        EM_REACTOR_MUTEX.synchronize(&block)
      end

      def self.aes_cmac_hex(key_hex, message_hex)
        key = [key_hex].pack('H*')
        message = [message_hex].pack('H*')
        aes_cmac(key, message).unpack1('H*')
      end

      def self.aes_cmac(key, message)
        key = key.b
        message = message.b
        block_size = 16
        const_rb = ("\x00".b * 15) + "\x87".b
        zero = "\x00".b * block_size
        l = aes_encrypt_block(key, zero)
        k1 = subkey(l, const_rb)
        k2 = subkey(k1, const_rb)

        n = [(message.bytesize.to_f / block_size).ceil, 1].max
        complete = message.bytesize.positive? && (message.bytesize % block_size).zero?
        last_block = message.byteslice((n - 1) * block_size, block_size) || ''.b
        last_block = if complete
                       xor_bytes(last_block, k1)
                     else
                       xor_bytes(pad(last_block, block_size), k2)
                     end

        x = zero
        (0...(n - 1)).each do |idx|
          block = message.byteslice(idx * block_size, block_size)
          x = aes_encrypt_block(key, xor_bytes(x, block))
        end
        aes_encrypt_block(key, xor_bytes(x, last_block))
      end

    private
      attr_reader :request

      def fetch_device_information
        @result = {}
        @session = {}
        @request = Request.new(session)
        pending = {}
        attempted_logout = false

        self.class.with_eventmachine_lock do
          EM.run do
            ws = Faye::WebSocket::Client.new(ws_url, ['cobra'], ping: 15, tls: tls_options)
            send_request = lambda do |message, action|
              msg_id = JSON.parse(message).dig('header', 'msgId')
              pending[msg_id] = action
              ws.send(message)
            end
            close_after_logout = lambda do
              if session[:management_session_id].present? && !attempted_logout
                attempted_logout = true
                send_request.call(request.logout, :logout)
              else
                ws.close
              end
            end
            timeout = EM::Timer.new(15) do
              if @result[:message].blank? && !@result[:success]
                @result = { success: false, message: 'Timeout while requesting device information' }
              end
              close_after_logout.call
            end

            ws.on :open do |_event|
              debug('>>> :open cherry remote management get-info >>>')
              send_request.call(request.login(ws_auth_user, ws_auth_pass), :login)
            end

            ws.on :message do |event|
              response = parse_ws_response(event.data)
              unless response
                if session[:management_session_id].present? && !attempted_logout
                  attempted_logout = true
                  send_request.call(request.logout, :logout)
                else
                  ws.close
                end
                next
              end

              debug2(response)
              action = pending[response.in_reply_to_id]
              if response.in_reply_to_id.blank? || action.blank?
                if @result[:success] && attempted_logout
                  ws.close
                  next
                end

                @result = {
                  success: false,
                  message: "Unexpected ST-1506 management response: unknown inReplyToId #{response.in_reply_to_id.presence || '(missing)'}"
                }
                close_after_logout.call
                next
              end

              unless response.success?
                if action == :logout
                  ws.close
                  next
                end

                @result = { success: false, message: response.error.to_s }
                if session[:management_session_id].present? && action != :login && !attempted_logout
                  attempted_logout = true
                  send_request.call(request.logout, :logout)
                else
                  ws.close
                end
                next
              end

              case action
              when :login
                if response.payload_type != 'LoginResponse'
                  @result = { success: false, message: "Unexpected ST-1506 management response for LoginRequest: #{response.payload_type}" }
                  ws.close
                elsif response.session_id.blank?
                  @result = { success: false, message: 'Login response did not contain a session id' }
                  ws.close
                else
                  session[:management_session_id] = response.session_id
                  send_request.call(request.get_device_information, :get_device_information)
                end
              when :get_device_information
                information = response.device_information
                if response.get_device_information_response? && information.present?
                  @result = {
                    success: true,
                    message: 'Device information received',
                    value: Info.new(information)
                  }
                  attempted_logout = true
                  send_request.call(request.logout, :logout)
                else
                  @result = { success: false, message: "Unexpected ST-1506 management response for GetDeviceInformationRequest: #{response.payload_type}" }
                  if session[:management_session_id].present? && !attempted_logout
                    attempted_logout = true
                    send_request.call(request.logout, :logout)
                  else
                    ws.close
                  end
                end
              when :logout
                ws.close
              else
                @result = { success: false, message: "Unexpected ST-1506 management action #{action}" }
                close_after_logout.call
              end
            end

            ws.on :error do |event|
              @result = { success: false, message: event.message } unless @result[:success]
              debug([:error, event.message])
              close_after_logout.call
            end

            ws.on :close do |event|
              timeout.cancel if timeout
              debug([:close, event.code, event.reason])
              ws = nil
              EM.stop
            end
          end
        end

        if @result[:success]
          Result.new(success?: true, message: @result[:message], value: @result[:value])
        else
          Result.new(success?: false, message: @result[:message] || 'Could not request device information')
        end
      end

      def fetch_smcb_authentication_key
        @result = {}
        @session = {}
        @request = Request.new(session)
        pending = {}

        self.class.with_eventmachine_lock do
          EM.run do
            ws = Faye::WebSocket::Client.new(ws_url, ['cobra'], ping: 15, tls: tls_options)
            timeout = EM::Timer.new(15) do
              unless @result[:success]
                @result = { success: false, message: 'Timeout while requesting SMC-B authentication key' }
              end
              ws.close
            end

            send_request = lambda do |message, action|
              msg_id = JSON.parse(message).dig('header', 'msgId')
              pending[msg_id] = action
              ws.send(message)
            end

            ws.on :open do |_event|
              debug('>>> :open cherry remote management >>>')
              send_request.call(request.login(ws_auth_user, ws_auth_pass), :login)
            end

            ws.on :message do |event|
              response = parse_ws_response(event.data)
              unless response
                ws.close
                next
              end

              debug2(response)
              action = pending[response.in_reply_to_id]

              unless response.success?
                if @result[:success] && action == :logout
                  ws.close
                  next
                end

                @result = { success: false, message: response.error.to_s }
                ws.close
                next
              end

              case action
              when :login
                session[:management_session_id] = response.session_id
                send_request.call(request.smcb_authentication, :smcb_authentication)
              when :smcb_authentication
                if response.key.present?
                  @result = { success: true, message: 'SMC-B authentication key received', key: response.key }
                  send_request.call(request.logout, :logout)
                else
                  @result = { success: false, message: 'SMC-B authentication response did not contain a key' }
                  ws.close
                end
              when :logout
                ws.close
              end
            end

            ws.on :error do |event|
              @result = { success: false, message: event.message } unless @result[:success]
              debug([:error, event.message])
              ws.close
            end

            ws.on :close do |event|
              timeout.cancel if timeout
              debug([:close, event.code, event.reason])
              ws = nil
              EM.stop
            end
          end
        end

        if @result[:success]
          Result.new(success?: true, message: @result[:message], value: @result[:key])
        else
          Result.new(success?: false, message: @result[:message] || 'Could not request SMC-B authentication key')
        end
      end

      def verify_pin_preflight(iccsn)
        unless rmi_port_reachable?
          return Result.new(success?: false, message: "RMI-Port #{rmi_port} unreachable!")
        end

        unless valid_smcb_pin?
          return Result.new(success?: false, message: 'DEFAULT_SMCB_PIN must be 6 to 8 digits!')
        end
        if ws_auth_pass.blank?
          return Result.new(success?: false, message: 'DEFAULT_WS_AUTH_PASS is not configured!')
        end

        card_slot_result = card_terminal_slot_for(iccsn)
        return card_slot_result unless card_slot_result.success?

        key_result = fetch_smcb_authentication_key
        return key_result unless key_result.success?
        unless valid_hex?(key_result.value, 64)
          return Result.new(success?: false, message: 'Invalid ST-1506 SMC-B authentication key')
        end

        Result.new(success?: true, message: 'ST-1506 PIN verification preflight complete', value: {
          key: key_result.value,
          slot_id: card_slot_result.value.slotid
        })
      end

      def connect_remote_smcb_api(key, authorized_slot_id)
        @result = {}
        @session = {}
        @request = Request.new(session)
        pending_pin_notifies = 0
        confirmed_pin_responses = 0

        self.class.with_eventmachine_lock do
          EM.run do
            ws = Faye::WebSocket::Client.new(ws_url, ['cobra-smcb'], ping: 15, tls: tls_options)
            timeout = EM::Timer.new(smcb_total_timeout_seconds) do
              next if confirmed_pin_responses.positive?

              @result = { success: false, message: 'Timeout waiting for ST-1506 PIN request' }
              ws.close
            end
            idle_timeout = nil
            cancel_total_timeout = lambda do
              timeout.cancel if timeout
              timeout = nil
            end
            cancel_idle_timeout = lambda do
              idle_timeout.cancel if idle_timeout
              idle_timeout = nil
            end
            schedule_idle_timeout = lambda do
              next unless confirmed_pin_responses.positive? && pending_pin_notifies.zero?

              cancel_total_timeout.call
              cancel_idle_timeout.call
              idle_timeout = EM::Timer.new(smcb_idle_timeout_seconds) do
                @result = { success: true, message: 'PIN Verification complete' }
                ws.close
              end
            end

            ws.on :open do |_event|
              debug('>>> :open cherry remote SMC-B >>>')
            end

            ws.on :message do |event|
              response = parse_ws_response(event.data)
              unless response
                ws.close
                next
              end

              debug2(response)
              session[:smcb_session_id] = response.session_id if response.session_id.present?

              if response.authenticate_request?
                unless valid_authenticate_request?(response)
                  @result = { success: false, message: 'Invalid ST-1506 SMC-B authenticate request' }
                  ws.close
                  next
                end

                cmac = self.class.aes_cmac_hex(key, response.challenge)
                ws.send(request.authenticate_response(response.msg_id, cmac))
              elsif response.notify?
                if response.success?
                  if pending_pin_notifies.positive?
                    pending_pin_notifies -= 1
                    confirmed_pin_responses += 1
                    @result = { success: true, message: 'PIN Verification complete' }
                    schedule_idle_timeout.call
                  end
                else
                  @result = { success: false, message: "ST-1506 notify code #{response.notify_code}" }
                  ws.close
                end
              elsif response.input_pin_request?
                unless authorized_pin_request?(response, authorized_slot_id)
                  @result = { success: false, message: 'ST-1506 PIN request slot is not authorized for this card' }
                  ws.close
                  next
                end

                unless pin_allowed_for_request?(response)
                  @result = { success: false, message: 'Configured SMC-B PIN violates ST-1506 PIN length request' }
                  ws.close
                  next
                end

                cancel_idle_timeout.call
                pending_pin_notifies += 1
                toaster(:info, 'PIN-Anfrage vom ST-1506 erhalten, sende SMC-B PIN ...')
                ws.send(request.input_pin_response(response.msg_id, smcb_pin))
              elsif response.output_request?
                unless authorized_output_request?(response, authorized_slot_id)
                  @result = { success: false, message: 'ST-1506 output request slot is not authorized for this card' }
                  ws.close
                  next
                end

                schedule_idle_timeout.call
                handle_output_request(ws, response)
              elsif response.cancel?
                @result = { success: false, message: 'ST-1506 canceled PIN request' }
                ws.close
              end
            end

            ws.on :error do |event|
              @result = { success: false, message: event.message }
              debug([:error, event.message])
              ws.close
            end

            ws.on :close do |event|
              timeout.cancel if timeout
              idle_timeout.cancel if idle_timeout
              debug([:close, event.code, event.reason])
              ws = nil
              EM.stop
            end
          end
        end

        if @result[:success]
          Result.new(success?: true, message: @result[:message])
        else
          Result.new(success?: false, message: @result[:message] || 'PIN Verification failed')
        end
      end

      def connect_remote_smcb_api_while(key, authorized_slot_id)
        @result = {}
        @session = {}
        @request = Request.new(session)
        listener_ready_events = Queue.new
        auth_events = Queue.new
        pending_pin_notifies = 0
        block_finished = false
        block_value = nil
        authenticated = false
        listener_ready_signaled = false
        auth_signaled = false
        closed = false
        ws = nil
        close_when_block_done = nil

        signal_listener_ready = lambda do
          next if listener_ready_signaled

          listener_ready_signaled = true
          listener_ready_events << true
        end
        signal_auth = lambda do |status|
          next if auth_signaled

          auth_signaled = true
          auth_events << status
        end
        close_listener = lambda do
          listener_ws = ws
          next unless listener_ws

          schedule_on_eventmachine do
            listener_ws.close
          end
        end

        listener_thread = Thread.new do
          execute_with_rails_executor do
            self.class.with_eventmachine_lock do
              signal_listener_ready.call

              EM.run do
                ws = Faye::WebSocket::Client.new(ws_url, ['cobra-smcb'], ping: 15, tls: tls_options)
                auth_timeout = EM::Timer.new(smcb_total_timeout_seconds) do
                  next if authenticated || @result[:success] || @result[:message].present?

                  @result = { success: false, message: 'Timeout during ST-1506 block PIN verification' }
                  signal_auth.call(:failed)
                  ws.close
                end
                pending_notify_timeout = nil
                cancel_pending_notify_timeout = lambda do
                  pending_notify_timeout.cancel if pending_notify_timeout
                  pending_notify_timeout = nil
                end

                close_with_failure = lambda do |message|
                  next if closed

                  cancel_pending_notify_timeout.call
                  @result = { success: false, message: message }
                  signal_auth.call(:failed) unless authenticated
                  ws.close
                end
                schedule_pending_notify_timeout = lambda do
                  cancel_pending_notify_timeout.call
                  pending_notify_timeout = EM::Timer.new(smcb_idle_timeout_seconds) do
                    next if closed || pending_pin_notifies.zero?

                    close_with_failure.call('Timeout waiting for ST-1506 PIN notify completion')
                  end
                end
                close_when_block_done = lambda do
                  next if closed
                  next unless block_finished && pending_pin_notifies.zero?

                  cancel_pending_notify_timeout.call
                  @result = { success: true, message: 'PIN Verification complete', value: block_value } unless @result[:message].present?
                  ws.close
                end

                ws.on :open do |_event|
                  debug('>>> :open cherry remote SMC-B block >>>')
                end

                ws.on :message do |event|
                  response = parse_ws_response(event.data)
                  unless response
                    signal_auth.call(:failed) unless authenticated
                    ws.close
                    next
                  end

                  debug2(response)
                  session[:smcb_session_id] = response.session_id if response.session_id.present?

                  if response.authenticate_request?
                    unless valid_authenticate_request?(response)
                      close_with_failure.call('Invalid ST-1506 SMC-B authenticate request')
                      next
                    end

                    cmac = self.class.aes_cmac_hex(key, response.challenge)
                    ws.send(request.authenticate_response(response.msg_id, cmac))
                    authenticated = true
                    auth_timeout.cancel if auth_timeout
                    auth_timeout = nil
                    signal_auth.call(:authenticated)
                  elsif !authenticated
                    close_with_failure.call("Unexpected ST-1506 SMC-B response before authentication: #{response.payload_type}")
                  elsif response.notify?
                    if response.success?
                      pending_pin_notifies -= 1 if pending_pin_notifies.positive?
                      cancel_pending_notify_timeout.call if pending_pin_notifies.zero?
                      close_when_block_done.call
                    else
                      close_with_failure.call("ST-1506 notify code #{response.notify_code}")
                    end
                  elsif response.input_pin_request?
                    unless authorized_pin_request?(response, authorized_slot_id)
                      close_with_failure.call('ST-1506 PIN request slot is not authorized for this card')
                      next
                    end

                    unless pin_allowed_for_request?(response)
                      close_with_failure.call('Configured SMC-B PIN violates ST-1506 PIN length request')
                      next
                    end

                    pending_pin_notifies += 1
                    schedule_pending_notify_timeout.call
                    toaster(:info, 'PIN-Anfrage vom ST-1506 erhalten, sende SMC-B PIN ...')
                    ws.send(request.input_pin_response(response.msg_id, smcb_pin))
                  elsif response.output_request?
                    unless authorized_output_request?(response, authorized_slot_id)
                      close_with_failure.call('ST-1506 output request slot is not authorized for this card')
                      next
                    end

                    handle_output_request(ws, response)
                    close_when_block_done.call
                  elsif response.cancel?
                    close_with_failure.call('ST-1506 canceled PIN request')
                  end
                end

                ws.on :error do |event|
                  @result = { success: false, message: event.message }
                  signal_auth.call(:failed) unless authenticated
                  debug([:error, event.message])
                  ws.close
                end

                ws.on :close do |event|
                  closed = true
                  signal_auth.call(:failed) unless authenticated
                  auth_timeout.cancel if auth_timeout
                  cancel_pending_notify_timeout.call
                  debug([:close, event.code, event.reason])
                  ws = nil
                  EM.stop
                end
              end
            end
          end
        end

        begin
          Timeout.timeout(smcb_total_timeout_seconds + 1) { listener_ready_events.pop }
          auth_status = Timeout.timeout(smcb_total_timeout_seconds) { auth_events.pop }

          if auth_status == :authenticated
            block_value = execute_with_rails_executor { yield }
            block_finished = true
            schedule_on_eventmachine do
              if @result[:message].present?
                close_listener.call
              else
                close_when_block_done.call
              end
            end
          end
        rescue Timeout::Error
          if listener_ready_signaled
            @result = { success: false, message: 'Timeout during ST-1506 PIN verification block' } unless @result[:message].present?
            close_listener.call
          else
            @result = { success: false, message: 'Timeout stopping ST-1506 block PIN verification listener' } unless @result[:message].present?
            listener_thread.kill unless listener_thread.join(1)
            listener_thread.join(1)
          end
        rescue StandardError => e
          @result = { success: false, message: "ST-1506 PIN verification block failed: #{e.message}" } unless @result[:message].present?
          close_listener.call
        ensure
          unless listener_thread.join(smcb_total_timeout_seconds + 1)
            @result = { success: false, message: 'Timeout stopping ST-1506 block PIN verification listener' } unless @result[:message].present?
            close_listener.call
            listener_thread.kill unless listener_thread.join(1)
            listener_thread.join(1)
          end
        end

        if @result[:success]
          Result.new(success?: true, message: @result[:message], value: @result[:value])
        else
          Result.new(success?: false, message: @result[:message] || 'PIN Verification failed')
        end
      end

      def handle_output_request(ws, response)
        toaster(:info, response.message) if response.message.present?
        return unless response.expect_response?

        code = response.ok_button? ? 'OkButton' : 'Error'
        ws.send(request.output_response(response.msg_id, code))
      end

      def schedule_on_eventmachine(&block)
        if EM.reactor_running?
          EM.schedule(&block)
        else
          block.call
        end
      end

      def execute_with_rails_executor
        if defined?(Rails) && Rails.respond_to?(:application) && Rails.application.respond_to?(:executor)
          Rails.application.executor.wrap { yield }
        else
          yield
        end
      end

      def parse_ws_response(data)
        Response.new(data)
      rescue JSON::ParserError => e
        @result = { success: false, message: "Invalid JSON from ST-1506: #{e.message}" } unless @result[:success]
        nil
      end

      def valid_hex?(value, length)
        value.to_s.match?(/\A[0-9a-f]{#{length}}\z/i)
      end

      def valid_smcb_pin?
        smcb_pin.to_s.match?(/\A\d{6,8}\z/)
      end

      def smcb_total_timeout_seconds
        60
      end

      def smcb_idle_timeout_seconds
        value = ENV['CHERRY_RMI_IDLE_TIMEOUT'].to_i
        value.positive? ? value : 15
      end

      def card_terminal_slot_for(iccsn)
        if iccsn.blank?
          return Result.new(success?: false, message: 'ICCSN is required for ST-1506 PIN verification')
        end

        card = Card.where('LOWER(iccsn) = ?', iccsn.to_s.downcase).first
        slot = card&.card_terminal_slot
        unless slot && slot.card_terminal_id == card_terminal.id
          return Result.new(success?: false, message: 'ICCSN is not assigned to this ST-1506 terminal slot')
        end

        Result.new(success?: true, message: 'Card slot authorized', value: slot)
      end

      def authorized_pin_request?(response, authorized_slot_id)
        authorized_slot_request?(response, authorized_slot_id)
      end

      def authorized_output_request?(response, authorized_slot_id)
        authorized_slot_request?(response, authorized_slot_id)
      end

      def authorized_slot_request?(response, authorized_slot_id)
        normalize_smcb_slot(smcb_payload_value(response, 'Slot')) == authorized_slot_id.to_i
      end

      def normalize_smcb_slot(slot)
        match = slot.to_s.match(/\ASlot([1-4])\z/)
        match && match[1].to_i
      end

      def valid_authenticate_request?(response)
        smcb_payload_value(response, 'ApiVersion') == '1.0' && valid_hex?(response.challenge, 64)
      end

      def pin_allowed_for_request?(response)
        pin_length = smcb_pin.to_s.length
        min_len = required_positive_integer(smcb_payload_value(response, 'MinLen'))
        max_len = required_positive_integer(smcb_payload_value(response, 'MaxLen'))

        return false if min_len.nil? || max_len.nil?
        return false if min_len > max_len
        return false if pin_length < min_len
        return false if pin_length > max_len

        true
      end

      def smcb_payload_value(response, key)
        payload = response.json['Payload'] || response.json[:Payload] || {}
        payload[key] || payload[key.to_sym]
      end

      def required_positive_integer(value)
        return nil if value.blank?

        string = value.to_s
        return nil unless string.match?(/\A\d+\z/)

        integer = string.to_i
        integer.positive? ? integer : nil
      end

      def tls_options
        options = { verify_peer: !insecure_tls_opt_out? }
        options[:ca_file] = ENV['CHERRY_RMI_CA_FILE'] if ENV['CHERRY_RMI_CA_FILE'].present?
        options[:ca_path] = ENV['CHERRY_RMI_CA_PATH'] if ENV['CHERRY_RMI_CA_PATH'].present?
        options
      end

      def insecure_tls_opt_out?
        ENV['CHERRY_RMI_INSECURE_TLS'].to_s.match?(/\A(?:1|true|yes)\z/i)
      end

      def ws_url
        port = configured_rmi_port
        return "wss://#{card_terminal.ip}" if port.blank?

        "wss://#{card_terminal.ip}:#{port}"
      end

      def configured_rmi_port
        if card_terminal.respond_to?(:has_attribute?) && card_terminal.has_attribute?(:rmi_port)
          return card_terminal[:rmi_port]
        end

        return nil if default_card_terminal_rmi_port_method?
        return nil unless card_terminal.respond_to?(:rmi_port)

        card_terminal.rmi_port
      end

      def default_card_terminal_rmi_port_method?
        card_terminal.respond_to?(:default_rmi_port) &&
          card_terminal.method(:rmi_port).owner == CardTerminalConcerns
      rescue NameError
        false
      end

      def ws_auth_user
        ENV['DEFAULT_WS_AUTH_USER'] || 'admin'
      end

      def ws_auth_pass
        ENV['DEFAULT_WS_AUTH_PASS']
      end

      def smcb_pin
        ENV['DEFAULT_SMCB_PIN']
      end

      def toaster(status, message)
        Turbo::StreamsChannel.broadcast_prepend_to(
          'verify_pins',
          target: 'toaster',
          partial: 'shared/turbo_toast',
          locals: { status: status, message: message }
        )
      end

      def debug(message)
        logger.debug("CardTerminal(#{card_terminal.id})::CherryRMI: #{message}")
      end

      def debug2(response)
        debug("PayloadType: #{response.payload_type}")
        debug("MsgId: #{response.msg_id}")
        debug("InReplyToId: #{response.in_reply_to_id}")
        debug('SessionId: [REDACTED]') if response.session_id.present?
      end

      def rmi_port_reachable?
        card_terminal.tcp_port_open?(rmi_port)
      end

      def session
        @session ||= {}
      end

      def self.postgresql_advisory_lock_available?
        defined?(ActiveRecord::Base) &&
          ActiveRecord::Base.connection_pool.with_connection do |connection|
            connection.adapter_name == 'PostgreSQL'
          end
      end

      def self.with_postgresql_advisory_lock(terminal_id)
        lock_object_id = advisory_lock_object_id(terminal_id)

        loop do
          ActiveRecord::Base.connection_pool.with_connection do |connection|
            if postgresql_advisory_lock_acquired?(connection, lock_object_id)
              begin
                return yield
              ensure
                postgresql_advisory_unlock(connection, lock_object_id)
              end
            end
          end

          sleep 0.25
        end
      end

      def self.with_terminal_mutex(terminal_id)
        terminal_mutex_for(terminal_id).synchronize { yield }
      end

      def self.terminal_mutex_for(terminal_id)
        key = terminal_mutex_key(terminal_id)
        TERMINAL_MUTEXES_MUTEX.synchronize do
          TERMINAL_MUTEXES[key] ||= Mutex.new
        end
      end

      def self.terminal_mutex_key(terminal_id)
        terminal_id.presence || :unknown_terminal
      end

      def self.advisory_lock_object_id(terminal_id)
        lock_id = terminal_id.to_i
        lock_id = terminal_id.to_s.each_byte.reduce(0) { |sum, byte| ((sum * 31) + byte) % 2_147_483_647 } if lock_id.zero?
        lock_id
      end

      def self.postgresql_advisory_lock_acquired?(connection, lock_object_id)
        result = connection.select_value(
          "SELECT pg_try_advisory_lock(#{VERIFY_PIN_LOCK_CLASS_ID}, #{lock_object_id})"
        )
        result == true || result.to_s == 't'
      rescue ActiveRecord::ActiveRecordError => e
        raise AdvisoryLockUnavailable, e.message
      end

      def self.postgresql_advisory_unlock(connection, lock_object_id)
        connection.select_value(
          "SELECT pg_advisory_unlock(#{VERIFY_PIN_LOCK_CLASS_ID}, #{lock_object_id})"
        )
      rescue ActiveRecord::ActiveRecordError => e
        Rails.logger.warn("Cherry ST-1506 advisory unlock failed for terminal lock #{lock_object_id}: #{e.message}") if defined?(Rails)
      end

      private_class_method :postgresql_advisory_lock_available?,
        :with_postgresql_advisory_lock,
        :with_terminal_mutex,
        :terminal_mutex_for,
        :terminal_mutex_key,
        :advisory_lock_object_id,
        :postgresql_advisory_lock_acquired?,
        :postgresql_advisory_unlock

      def self.aes_encrypt_block(key, block)
        cipher = OpenSSL::Cipher.new('AES-256-ECB')
        cipher.encrypt
        cipher.padding = 0
        cipher.key = key
        cipher.update(block) + cipher.final
      end

      def self.subkey(block, const_rb)
        shifted = left_shift_one_bit(block)
        (block.getbyte(0) & 0x80).zero? ? shifted : xor_bytes(shifted, const_rb)
      end

      def self.left_shift_one_bit(block)
        carry = 0
        block.bytes.reverse.map do |byte|
          shifted = ((byte << 1) & 0xff) | carry
          carry = (byte & 0x80).zero? ? 0 : 1
          shifted
        end.reverse.pack('C*')
      end

      def self.pad(block, block_size)
        block.b + "\x80".b + ("\x00".b * (block_size - block.bytesize - 1))
      end

      def self.xor_bytes(left, right)
        left.bytes.zip(right.bytes).map { |a, b| a ^ b }.pack('C*')
      end
    end
  end
end
