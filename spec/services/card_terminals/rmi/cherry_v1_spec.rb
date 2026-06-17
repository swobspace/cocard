# frozen_string_literal: true

require 'rails_helper'
require 'ostruct'
require 'timeout'

module CardTerminals
  class RMI
    RSpec.describe CherryV1 do
      def with_env(values)
        old_values = values.keys.index_with { |key| ENV[key] }
        values.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
        yield
      ensure
        old_values.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
      end

      describe '.aes_cmac_hex' do
        let(:key) do
          '603deb1015ca71be2b73aef0857d7781' \
            '1f352c073b6108d72d9810a30914dff4'
        end

        it 'matches the RFC 4493 AES-256 CMAC empty-message test vector' do
          expect(described_class.aes_cmac_hex(key, '')).to eq('028962f61b7bf89efc6b551f4667d983')
        end

        it 'matches the RFC 4493 AES-256 CMAC one-block test vector' do
          message = '6bc1bee22e409f96e93d7e117393172a'
          expect(described_class.aes_cmac_hex(key, message)).to eq('28a7023f452e8f82bd4bf28d8c37c35c')
        end

        it 'handles binary key bytes and UTF-8 empty messages without encoding errors' do
          binary_key = [key].pack('H*').force_encoding(Encoding::UTF_8)

          expect { described_class.aes_cmac(binary_key, '') }.not_to raise_error
        end
      end

      describe CherryV1::Request do
        it 'uses lowercase management envelope fields' do
          json = JSON.parse(described_class.new({}).login('admin', 'secret'))

          expect(json).to include('payloadType' => 'LoginRequest')
          expect(json['header']).to include('msgId')
          expect(json['header']).not_to include('sessionId')
          expect(json['payload']).to include('username' => 'admin', 'password' => 'secret')
        end

        it 'uses uppercase SMC-B envelope fields and PIN payload casing' do
          session = { smcb_session_id: 'smcb-session' }
          json = JSON.parse(described_class.new(session).input_pin_response('request-id', '123456'))

          expect(json).to include('PayloadType' => 'InputPinResponse')
          expect(json['Header']).to include('MsgId', 'InReplyToId' => 'request-id', 'SessionId' => 'smcb-session')
          expect(json['Payload']).to eq('Code' => 'Pin', 'Pin' => '123456')
        end
      end

      describe CherryV1::Response do
        it 'requires an explicit zero notify code for success' do
          expect(response_for('PayloadType' => 'Notify', 'Payload' => { 'Code' => 0 })).to be_success
          expect(response_for('PayloadType' => 'Notify', 'Payload' => { 'Code' => '0' })).to be_success
          expect(response_for('PayloadType' => 'Notify', 'Payload' => { 'Code' => nil })).not_to be_success
          expect(response_for('PayloadType' => 'Notify', 'Payload' => { 'Code' => 'success' })).not_to be_success
          expect(response_for('PayloadType' => 'Notify', 'Payload' => {})).not_to be_success
        end

        it 'reads the SMC-B request Slot field' do
          expect(response_for('PayloadType' => 'InputPinRequest', 'Payload' => { 'Slot' => 'Slot3' }).slot).to eq('Slot3')
        end

        it 'reads management session ids from the protocol payload and legacy header variant' do
          expect(response_for('payload' => { 'sessionId' => 'payload-session' }).session_id).to eq('payload-session')
          expect(response_for('header' => { 'SessionId' => 'legacy-header-session' }).session_id).to eq('legacy-header-session')
        end

        def response_for(message)
          described_class.new(message.to_json)
        end
      end

      describe '#rmi_port' do
        it 'uses the Cherry default port without recursing through CardTerminal#rmi_port' do
          card_terminal = FactoryBot.create(:card_terminal, :with_mac, ip: '192.0.2.10')

          expect(described_class.new(card_terminal: card_terminal).rmi_port).to eq(443)
        end
      end

      describe '#verify_pin' do
        let(:card_terminal) { FactoryBot.create(:card_terminal, :with_mac, ip: '192.0.2.10') }
        let(:service) { described_class.new(card_terminal: card_terminal) }
        let(:key_result) { described_class::Result.new(success?: true, message: 'key', value: 'a' * 64) }

        before do
          allow(card_terminal).to receive(:rmi_port).and_return(8443)
          allow(card_terminal).to receive(:tcp_port_open?).with(8443).and_return(true)
        end

        it 'validates DEFAULT_SMCB_PIN before opening the SMC-B flow' do
          with_env('DEFAULT_SMCB_PIN' => '12ab56', 'DEFAULT_WS_AUTH_PASS' => 'secret') do
            expect(service).not_to receive(:fetch_smcb_authentication_key)
            expect(service).not_to receive(:connect_remote_smcb_api)

            result = service.verify_pin('802760000000000001')

            expect(result).not_to be_success
            expect(result.message).to match(/DEFAULT_SMCB_PIN/)
          end
        end

        it 'fails closed before SMC-B contact when the ICCSN is blank' do
          with_env('DEFAULT_SMCB_PIN' => '123456', 'DEFAULT_WS_AUTH_PASS' => 'secret') do
            expect(service).not_to receive(:fetch_smcb_authentication_key)
            expect(service).not_to receive(:connect_remote_smcb_api)

            result = service.verify_pin('')

            expect(result).not_to be_success
            expect(result.message).to match(/ICCSN is required/)
          end
        end

        it 'fails closed when the ICCSN cannot be correlated to this terminal slot' do
          other_terminal = FactoryBot.create(:card_terminal, :with_mac)
          other_slot = FactoryBot.create(:card_terminal_slot, card_terminal: other_terminal, slotid: 1)
          FactoryBot.create(:card, iccsn: '802760000000000002', card_terminal_slot: other_slot)

          with_env('DEFAULT_SMCB_PIN' => '123456', 'DEFAULT_WS_AUTH_PASS' => 'secret') do
            expect(service).not_to receive(:fetch_smcb_authentication_key)
            expect(service).not_to receive(:connect_remote_smcb_api)

            result = service.verify_pin('802760000000000002')

            expect(result).not_to be_success
            expect(result.message).to match(/not assigned/)
          end
        end

        it 'uses the requested ICCSN slot when starting the SMC-B flow' do
          slot = FactoryBot.create(:card_terminal_slot, card_terminal: card_terminal, slotid: 1)
          FactoryBot.create(:card, iccsn: '802760000000000003', card_terminal_slot: slot)

          with_env('DEFAULT_SMCB_PIN' => '123456', 'DEFAULT_WS_AUTH_PASS' => 'secret') do
            expect(service).to receive(:fetch_smcb_authentication_key).and_return(key_result)
            expect(service).to receive(:connect_remote_smcb_api).with('a' * 64, 1)
              .and_return(described_class::Result.new(success?: true, message: 'ok'))

            expect(service.verify_pin('802760000000000003')).to be_success
          end
        end

        it 'serializes concurrent Cherry verify_pin calls for the same terminal with the fallback terminal mutex' do
          allow(described_class).to receive(:postgresql_advisory_lock_available?).and_return(false)
          stub_const('CardTerminals::RMI::CherryV1::TERMINAL_MUTEXES', {})
          stub_const('CardTerminals::RMI::CherryV1::TERMINAL_MUTEXES_MUTEX', Mutex.new)

          release_first_call = Queue.new
          entered_body = Queue.new
          pop_with_timeout = ->(queue) { Timeout.timeout(1) { queue.pop } }

          allow(service).to receive(:verify_pin_without_lock) do |iccsn|
            entered_body << iccsn
            release_first_call.pop if iccsn == 'first'
            described_class::Result.new(success?: true, message: iccsn)
          end

          first_thread = Thread.new { service.verify_pin('first') }
          expect(pop_with_timeout.call(entered_body)).to eq('first')

          second_thread = Thread.new { service.verify_pin('second') }
          sleep 0.05
          expect(entered_body).to be_empty

          release_first_call << true
          expect(first_thread.value.message).to eq('first')
          expect(pop_with_timeout.call(entered_body)).to eq('second')
          expect(second_thread.value.message).to eq('second')
        ensure
          release_first_call << true if defined?(release_first_call)
          first_thread&.join(1)
          second_thread&.join(1)
        end

        it 'uses a terminal-scoped PostgreSQL advisory lock key' do
          connection = instance_double('ActiveRecord::Connection')
          connection_pool = instance_double('ActiveRecord::ConnectionAdapters::ConnectionPool')

          allow(described_class).to receive(:postgresql_advisory_lock_available?).and_return(true)
          allow(ActiveRecord::Base).to receive(:connection_pool).and_return(connection_pool)
          allow(connection_pool).to receive(:with_connection).and_yield(connection)
          allow(connection).to receive(:select_value).with("SELECT pg_try_advisory_lock(20240617, #{card_terminal.id})").and_return(true)
          allow(connection).to receive(:select_value).with("SELECT pg_advisory_unlock(20240617, #{card_terminal.id})").and_return(true)
          allow(service).to receive(:verify_pin_without_lock)
            .and_return(described_class::Result.new(success?: true, message: 'ok'))

          expect(service.verify_pin('802760000000000003')).to be_success
          expect(connection).to have_received(:select_value).with("SELECT pg_try_advisory_lock(20240617, #{card_terminal.id})")
        end

        it 'does not re-run PIN verification when PostgreSQL advisory unlock fails after the body ran' do
          connection = instance_double('ActiveRecord::Connection')
          connection_pool = instance_double('ActiveRecord::ConnectionAdapters::ConnectionPool')
          body_calls = 0

          allow(described_class).to receive(:postgresql_advisory_lock_available?).and_return(true)
          allow(ActiveRecord::Base).to receive(:connection_pool).and_return(connection_pool)
          allow(connection_pool).to receive(:with_connection).and_yield(connection)
          allow(connection).to receive(:select_value).with("SELECT pg_try_advisory_lock(20240617, #{card_terminal.id})").and_return(true)
          allow(connection).to receive(:select_value).with("SELECT pg_advisory_unlock(20240617, #{card_terminal.id})")
            .and_raise(ActiveRecord::StatementInvalid.new('unlock failed'))
          allow(Rails.logger).to receive(:warn)
          allow(service).to receive(:verify_pin_without_lock) do |iccsn|
            body_calls += 1
            described_class::Result.new(success?: true, message: iccsn)
          end

          result = service.verify_pin('802760000000000003')

          expect(result).to be_success
          expect(body_calls).to eq(1)
        end
      end

      describe '#connect_remote_smcb_api' do
        let(:card_terminal) { instance_double(CardTerminal, id: 1, ip: '192.0.2.10', rmi_port: 8443) }
        let(:service) { described_class.new(card_terminal: card_terminal) }
        let(:websocket) { FakeWebSocket.new }
        let(:key) { 'a' * 64 }
        let(:timer) { instance_double(EM::Timer, cancel: true) }

        before do
          allow(Faye::WebSocket::Client).to receive(:new).and_return(websocket)
          @timer_callbacks = {}
          allow(EM::Timer).to receive(:new) do |seconds, &block|
            @timer_callbacks[seconds] = block
            @timer_callback = block
            timer
          end
          allow(EM).to receive(:stop)
          allow(EM).to receive(:run) do |&block|
            block.call
            @exercise_websocket.call
          end
          allow(service).to receive(:toaster)
        end

        it 'keeps the listener open after a PIN notify, answers multiple authorized PIN requests, and succeeds on timeout after confirmation' do
          @exercise_websocket = lambda do
            websocket.emit_message(authenticate_request)
            websocket.emit_message(input_pin_request('pin-1', 'Slot1'))
            expect(websocket.close_count).to eq(0)

            websocket.emit_message(success_notify('notify-1'))
            expect(websocket.close_count).to eq(0)

            websocket.emit_message(input_pin_request('pin-2', 'Slot1'))
            websocket.emit_message(success_notify('notify-2'))

            @timer_callbacks[60].call
            expect(websocket.close_count).to eq(0)

            @timer_callbacks[15].call
          end

          result = with_env('DEFAULT_SMCB_PIN' => '123456') do
            service.send(:connect_remote_smcb_api, key, 1)
          end

          payload_types = websocket.sent.map { |message| JSON.parse(message)['PayloadType'] }
          expect(payload_types).to include('AuthenticateResponse')
          expect(payload_types.count('InputPinResponse')).to eq(2)
          expect(websocket.close_count).to eq(1)
          expect(result).to be_success
          expect(result.message).to eq('PIN Verification complete')
        end

        it 'returns a timeout failure when no PIN was confirmed before timeout' do
          @exercise_websocket = lambda do
            websocket.emit_message(authenticate_request)
            @timer_callbacks[60].call
          end

          with_env('DEFAULT_SMCB_PIN' => '123456') do
            result = service.send(:connect_remote_smcb_api, key, 1)

            expect(result).not_to be_success
            expect(result.message).to eq('Timeout waiting for ST-1506 PIN request')
          end
        end

        it 'uses CHERRY_RMI_IDLE_TIMEOUT after the first confirmed PIN notify' do
          @exercise_websocket = lambda do
            websocket.emit_message(authenticate_request)
            websocket.emit_message(input_pin_request('pin-1', 'Slot1'))
            websocket.emit_message(success_notify('notify-1'))

            expect(@timer_callbacks).to include(7)
            @timer_callbacks[7].call
          end

          result = with_env('DEFAULT_SMCB_PIN' => '123456', 'CHERRY_RMI_IDLE_TIMEOUT' => '7') do
            service.send(:connect_remote_smcb_api, key, 1)
          end

          expect(websocket.close_count).to eq(1)
          expect(result).to be_success
        end

        it 'closes immediately on an unauthorized PIN request without sending the PIN' do
          @exercise_websocket = lambda do
            websocket.emit_message(authenticate_request)
            websocket.emit_message(input_pin_request('pin-1', 'Slot2'))
          end

          result = with_env('DEFAULT_SMCB_PIN' => '123456') do
            service.send(:connect_remote_smcb_api, key, 1)
          end

          payload_types = websocket.sent.map { |message| JSON.parse(message)['PayloadType'] }
          expect(payload_types).not_to include('InputPinResponse')
          expect(websocket.close_count).to eq(1)
          expect(result).not_to be_success
          expect(result.message).to match(/not authorized/)
        end

        def authenticate_request
          {
            'PayloadType' => 'AuthenticateRequest',
            'Header' => { 'MsgId' => 'auth-1', 'SessionId' => 'session-1' },
            'Payload' => { 'ApiVersion' => '1.0', 'Challenge' => 'b' * 64 }
          }.to_json
        end

        def input_pin_request(msg_id, slot)
          {
            'PayloadType' => 'InputPinRequest',
            'Header' => { 'MsgId' => msg_id, 'SessionId' => 'session-1' },
            'Payload' => { 'Slot' => slot, 'MinLen' => 6, 'MaxLen' => 8 }
          }.to_json
        end

        def success_notify(msg_id)
          {
            'PayloadType' => 'Notify',
            'Header' => { 'MsgId' => msg_id, 'SessionId' => 'session-1' },
            'Payload' => { 'Code' => 0 }
          }.to_json
        end

        class FakeWebSocket
          attr_reader :close_count, :handlers, :sent

          def initialize
            @close_count = 0
            @handlers = {}
            @sent = []
          end

          def on(event, &block)
            handlers[event] = block
          end

          def send(message)
            sent << message
          end

          def close
            @close_count += 1
            handlers[:close]&.call(OpenStruct.new(code: 1000, reason: 'closed'))
          end

          def emit_message(data)
            handlers.fetch(:message).call(OpenStruct.new(data: data))
          end
        end
      end

      describe 'private helpers' do
        let(:card_terminal) { instance_double(CardTerminal, id: 1, ip: '192.0.2.10', rmi_port: 8443) }
        let(:service) { described_class.new(card_terminal: card_terminal) }

        it 'verifies TLS peers by default and supports configured CA file/path' do
          with_env(
            'CHERRY_RMI_INSECURE_TLS' => nil,
            'CHERRY_RMI_CA_FILE' => '/etc/cocard/cherry-ca.pem',
            'CHERRY_RMI_CA_PATH' => '/etc/cocard/certs'
          ) do
            expect(service.send(:tls_options)).to eq(
              verify_peer: true,
              ca_file: '/etc/cocard/cherry-ca.pem',
              ca_path: '/etc/cocard/certs'
            )
          end
        end

        it 'allows insecure TLS only through an explicit Cherry env opt-out' do
          with_env('CHERRY_RMI_INSECURE_TLS' => 'true', 'CHERRY_RMI_CA_FILE' => nil, 'CHERRY_RMI_CA_PATH' => nil) do
            expect(service.send(:tls_options)).to eq(verify_peer: false)
          end
        end

        it 'includes the configured RMI port in the websocket URL' do
          expect(service.send(:ws_url)).to eq('wss://192.0.2.10:8443')
        end

        it 'omits a websocket port only when no RMI port is configured' do
          allow(card_terminal).to receive(:rmi_port).and_return(nil)
          expect(service.send(:ws_url)).to eq('wss://192.0.2.10')
        end

        it 'probes the default HTTPS port when no RMI port is configured' do
          allow(card_terminal).to receive(:rmi_port).and_return(nil, '')
          allow(card_terminal).to receive(:tcp_port_open?).with(443).twice.and_return(true)

          expect(service.send(:rmi_port_reachable?)).to be(true)
          expect(service.send(:rmi_port_reachable?)).to be(true)
        end

        it 'authorizes PIN requests only for the requested protocol card slot' do
          matching_response = CherryV1::Response.new({ 'PayloadType' => 'InputPinRequest', 'Payload' => { 'Slot' => 'Slot1' } }.to_json)
          wrong_response = CherryV1::Response.new({ 'PayloadType' => 'InputPinRequest', 'Payload' => { 'Slot' => 'Slot2' } }.to_json)
          numeric_response = CherryV1::Response.new({ 'PayloadType' => 'InputPinRequest', 'Payload' => { 'Slot' => 1 } }.to_json)
          lower_case_response = CherryV1::Response.new({ 'PayloadType' => 'InputPinRequest', 'Payload' => { 'slot' => 'Slot1' } }.to_json)
          invalid_response = CherryV1::Response.new({ 'PayloadType' => 'InputPinRequest', 'Payload' => { 'Slot' => 'Slot7' } }.to_json)
          missing_response = CherryV1::Response.new({ 'PayloadType' => 'InputPinRequest', 'Payload' => {} }.to_json)

          expect(service.send(:authorized_pin_request?, matching_response, 1)).to be(true)
          expect(service.send(:authorized_pin_request?, wrong_response, 1)).to be(false)
          expect(service.send(:authorized_pin_request?, numeric_response, 1)).to be(false)
          expect(service.send(:authorized_pin_request?, lower_case_response, 1)).to be(false)
          expect(service.send(:authorized_pin_request?, invalid_response, 1)).to be(false)
          expect(service.send(:authorized_pin_request?, missing_response, 1)).to be(false)
        end

        it 'authorizes output requests only for the requested protocol card slot' do
          matching_response = CherryV1::Response.new({ 'PayloadType' => 'OutputRequest', 'Payload' => { 'Slot' => 'Slot3' } }.to_json)
          wrong_response = CherryV1::Response.new({ 'PayloadType' => 'OutputRequest', 'Payload' => { 'Slot' => 'Slot2' } }.to_json)
          numeric_response = CherryV1::Response.new({ 'PayloadType' => 'OutputRequest', 'Payload' => { 'Slot' => 3 } }.to_json)
          lower_case_response = CherryV1::Response.new({ 'PayloadType' => 'OutputRequest', 'Payload' => { 'slot' => 'Slot3' } }.to_json)
          invalid_response = CherryV1::Response.new({ 'PayloadType' => 'OutputRequest', 'Payload' => { 'Slot' => 'Slot7' } }.to_json)
          missing_response = CherryV1::Response.new({ 'PayloadType' => 'OutputRequest', 'Payload' => {} }.to_json)

          expect(service.send(:authorized_output_request?, matching_response, 3)).to be(true)
          expect(service.send(:authorized_output_request?, wrong_response, 3)).to be(false)
          expect(service.send(:authorized_output_request?, numeric_response, 3)).to be(false)
          expect(service.send(:authorized_output_request?, lower_case_response, 3)).to be(false)
          expect(service.send(:authorized_output_request?, invalid_response, 3)).to be(false)
          expect(service.send(:authorized_output_request?, missing_response, 3)).to be(false)
        end

        it 'requires SMC-B authenticate requests to include API version 1.0 and a valid challenge' do
          valid_response = CherryV1::Response.new({ 'PayloadType' => 'AuthenticateRequest', 'Payload' => { 'ApiVersion' => '1.0', 'Challenge' => 'a' * 64 } }.to_json)
          missing_version = CherryV1::Response.new({ 'PayloadType' => 'AuthenticateRequest', 'Payload' => { 'Challenge' => 'a' * 64 } }.to_json)
          wrong_version = CherryV1::Response.new({ 'PayloadType' => 'AuthenticateRequest', 'Payload' => { 'ApiVersion' => '2.0', 'Challenge' => 'a' * 64 } }.to_json)
          invalid_challenge = CherryV1::Response.new({ 'PayloadType' => 'AuthenticateRequest', 'Payload' => { 'ApiVersion' => '1.0', 'Challenge' => 'g' * 64 } }.to_json)

          expect(service.send(:valid_authenticate_request?, valid_response)).to be(true)
          expect(service.send(:valid_authenticate_request?, missing_version)).to be(false)
          expect(service.send(:valid_authenticate_request?, wrong_version)).to be(false)
          expect(service.send(:valid_authenticate_request?, invalid_challenge)).to be(false)
        end

        it 'sends the configured PIN only when it fits required request MinLen and MaxLen' do
          with_env('DEFAULT_SMCB_PIN' => '123456') do
            matching_response = CherryV1::Response.new({ 'PayloadType' => 'InputPinRequest', 'Payload' => { 'MinLen' => 6, 'MaxLen' => 8 } }.to_json)
            missing_min_response = CherryV1::Response.new({ 'PayloadType' => 'InputPinRequest', 'Payload' => { 'MaxLen' => 8 } }.to_json)
            missing_max_response = CherryV1::Response.new({ 'PayloadType' => 'InputPinRequest', 'Payload' => { 'MinLen' => 6 } }.to_json)
            no_limits_response = CherryV1::Response.new({ 'PayloadType' => 'InputPinRequest', 'Payload' => {} }.to_json)
            too_short_response = CherryV1::Response.new({ 'PayloadType' => 'InputPinRequest', 'Payload' => { 'MinLen' => 7, 'MaxLen' => 8 } }.to_json)
            too_long_response = CherryV1::Response.new({ 'PayloadType' => 'InputPinRequest', 'Payload' => { 'MinLen' => 4, 'MaxLen' => 5 } }.to_json)
            non_positive_limit_response = CherryV1::Response.new({ 'PayloadType' => 'InputPinRequest', 'Payload' => { 'MinLen' => 0, 'MaxLen' => 8 } }.to_json)
            invalid_limit_response = CherryV1::Response.new({ 'PayloadType' => 'InputPinRequest', 'Payload' => { 'MinLen' => 'six', 'MaxLen' => 8 } }.to_json)
            inverted_limits_response = CherryV1::Response.new({ 'PayloadType' => 'InputPinRequest', 'Payload' => { 'MinLen' => 8, 'MaxLen' => 6 } }.to_json)

            expect(service.send(:pin_allowed_for_request?, matching_response)).to be(true)
            expect(service.send(:pin_allowed_for_request?, missing_min_response)).to be(false)
            expect(service.send(:pin_allowed_for_request?, missing_max_response)).to be(false)
            expect(service.send(:pin_allowed_for_request?, no_limits_response)).to be(false)
            expect(service.send(:pin_allowed_for_request?, too_short_response)).to be(false)
            expect(service.send(:pin_allowed_for_request?, too_long_response)).to be(false)
            expect(service.send(:pin_allowed_for_request?, non_positive_limit_response)).to be(false)
            expect(service.send(:pin_allowed_for_request?, invalid_limit_response)).to be(false)
            expect(service.send(:pin_allowed_for_request?, inverted_limits_response)).to be(false)
          end
        end

        it 'does not log raw JSON or session material' do
          response = CherryV1::Response.new({
            'Header' => { 'MsgId' => 'msg', 'SessionId' => 'secret-session' },
            'PayloadType' => 'Notify',
            'Payload' => { 'Code' => 0, 'key' => 'secret-key' }
          }.to_json)
          allow(service).to receive(:debug)

          service.send(:debug2, response)

          expect(service).not_to have_received(:debug).with(/JSON|secret-session|secret-key/)
          expect(service).to have_received(:debug).with('SessionId: [REDACTED]')
        end
      end
    end
  end
end
