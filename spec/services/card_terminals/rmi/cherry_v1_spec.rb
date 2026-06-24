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

        it 'builds a GetDeviceInformationRequest with an empty payload and management session id' do
          session = { management_session_id: 'management-session' }
          json = JSON.parse(described_class.new(session).get_device_information)

          expect(json).to include('payloadType' => 'GetDeviceInformationRequest')
          expect(json['header']).to include('msgId', 'sessionId' => 'management-session')
          expect(json['payload']).to eq({})
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

        it 'exposes GetDeviceInformationResponse payload without breaking other response parsing' do
          response = response_for(
            'payloadType' => 'GetDeviceInformationResponse',
            'payload' => { 'deviceName' => 'Cherry', 'ipAddress' => '192.0.2.10' }
          )

          expect(response).to be_get_device_information_response
          expect(response.device_information).to eq('deviceName' => 'Cherry', 'ipAddress' => '192.0.2.10')
          expect(response_for('PayloadType' => 'InputPinRequest', 'Payload' => { 'Slot' => 'Slot3' }).slot).to eq('Slot3')
        end

        def response_for(message)
          described_class.new(message.to_json)
        end
      end

      describe '#available_actions' do
        it 'includes get_info and Cherry block verification while preserving verify_pin' do
          card_terminal = FactoryBot.create(:card_terminal, :with_mac, ip: '192.0.2.10')

          expect(described_class.new(card_terminal: card_terminal).available_actions).to contain_exactly(:verify_pin, :verify_pin_while, :get_info)
        end
      end

      describe '#rmi_port' do
        it 'uses the Cherry default port without recursing through CardTerminal#rmi_port' do
          card_terminal = FactoryBot.create(:card_terminal, :with_mac, ip: '192.0.2.10')

          expect(described_class.new(card_terminal: card_terminal).rmi_port).to eq(443)
        end
      end

      describe CherryV1::Info do
        let(:payload) do
          {
            'providerId' => 'DECHY',
            'productShortName' => 'ST1506',
            'deviceName' => 'Cherry ST-1506',
            'ethernetMacAddress' => 'aa:bb:cc:dd:ee:ff',
            'ipAddress' => '192.0.2.10',
            'useDhcp' => true,
            'networkMode' => 'Dhcp',
            'fwVersion' => '3.2.1',
            'buildVersion' => 'build-42',
            'remotepin1' => 0,
            'remotepin2' => 1,
            'ntpSyncServer' => '192.0.2.53',
            'smcktProductTypeVersion' => '2.0',
            'smcktSerialNumber' => 'CHERRY-SERIAL-123',
            'smcktPersonalization' => 'RSA,ECC',
            'smcktExpirationDateAUT' => '20270131',
            'smcktExpirationDateAUT2' => '20280229',
            'smcktExpirationDateAUTD' => 'invalid'
          }
        end

        it 'maps Cherry device information to the common info interface conservatively' do
          info = described_class.new(payload)

          expect(info.terminalname).to eq('Cherry ST-1506')
          expect(info.identification).to eq('DECHY-ST1506')
          expect(info.macaddr).to eq('AABBCCDDEEFF')
          expect(info.current_ip).to eq('192.0.2.10')
          expect(info.dhcp_enabled).to be(true)
          expect(info.dhcp_ip).to eq('192.0.2.10')
          expect(info.static_ip).to be_nil
          expect(info.remote_pin_enabled).to be(true)
          expect(info.ntp_enabled).to be(true)
          expect(info.ntp_server).to eq('192.0.2.53')
          expect(info.firmware_version).to eq('3.2.1')
          expect(info.build_version).to eq('build-42')
          expect(info.smckt_version).to eq('2.0')
          expect(info.smckt_iccsn).to be_nil
          expect(info.smckt_serial_number).to eq('CHERRY-SERIAL-123')
          expect(info.smckt_slot).to eq(0)
          expect(info.smckt_personalization).to eq('RSA,ECC')
          expect(info.smckt_auth1_type).to be_nil
          expect(info.smckt_auth1_expiration).to eq(Date.new(2027, 1, 31))
          expect(info.smckt_auth2_type).to be_nil
          expect(info.smckt_auth2_expiration).to eq(Date.new(2028, 2, 29))
          expect(info.smckt_autd_expiration).to be_nil
        end

        it 'derives DHCP from networkMode and returns nil/safe defaults for unavailable attributes' do
          info = described_class.new('networkMode' => 'StaticIp', 'ipAddress' => '192.0.2.20')

          expect(info.dhcp_enabled).to be(false)
          expect(info.static_ip).to eq('192.0.2.20')
          expect(info.dhcp_ip).to be_nil
          expect(info.macaddr).to be_nil
          expect(info.serial).to be_nil
          expect(info.uptime_total).to be_nil
          expect(info.slot1_plug_cycles).to be_nil
          expect(info.remote_pairing_enabled).to be_nil
          expect(info.tls_kt_ecgroup).to be_nil
        end

        it 'keeps SMC-KT personalization conservative for supported protocol values' do
          %w[RSA ECC RSA,ECC].each do |personalization|
            info = described_class.new('smcktPersonalization' => personalization)

            expect(info.smckt_personalization).to eq(personalization)
            expect(info.smckt_auth1_type).to be_nil
            expect(info.smckt_auth2_type).to be_nil
          end
        end
      end

      describe '#get_info' do
        let(:card_terminal) { instance_double(CardTerminal, id: 1, ip: '192.0.2.10', rmi_port: 8443) }
        let(:service) { described_class.new(card_terminal: card_terminal) }
        let(:websocket) { FakeManagementWebSocket.new }
        let(:timer) { instance_double(EM::Timer, cancel: true) }

        before do
          allow(card_terminal).to receive(:tcp_port_open?).with(8443).and_return(true)
          allow(Faye::WebSocket::Client).to receive(:new).and_return(websocket)
          allow(EM::Timer).to receive(:new).and_return(timer)
          allow(EM).to receive(:stop)
          allow(EM).to receive(:run) do |&block|
            block.call
            websocket.emit_open
          end
        end

        it 'validates websocket credentials before opening the management websocket' do
          with_env('DEFAULT_WS_AUTH_PASS' => nil) do
            expect(Faye::WebSocket::Client).not_to receive(:new)

            result = service.get_info

            expect(result).not_to be_success
            expect(result.message).to match(/DEFAULT_WS_AUTH_PASS/)
          end
        end

        it 'logs in, requests device information, logs out, and returns Cherry info' do
          websocket.on_send('LoginRequest') do |request|
            websocket.emit_message(
              'header' => { 'msgId' => 'login-response', 'inReplyToId' => request.dig('header', 'msgId') },
              'payloadType' => 'LoginResponse',
              'payload' => { 'sessionId' => 'management-session' }
            )
          end
          websocket.on_send('GetDeviceInformationRequest') do |request|
            expect(request.dig('header', 'sessionId')).to eq('management-session')
            websocket.emit_message(
              'header' => { 'msgId' => 'info-response', 'inReplyToId' => request.dig('header', 'msgId') },
              'payloadType' => 'GetDeviceInformationResponse',
              'payload' => { 'providerId' => 'DECHY', 'productShortName' => 'ST1506', 'deviceName' => 'Cherry' }
            )
          end
          websocket.on_send('LogoutRequest') { websocket.close }

          result = with_env('DEFAULT_WS_AUTH_PASS' => 'secret') { service.get_info }

          expect(result).to be_success
          expect(result.message).to eq('Device information received')
          expect(result.value).to be_a(CherryV1::Info)
          expect(result.value.identification).to eq('DECHY-ST1506')
          expect(websocket.sent_payload_types).to eq(%w[LoginRequest GetDeviceInformationRequest LogoutRequest])
        end

        it 'preserves successful device information when cleanup logout response has no inReplyToId' do
          websocket.on_send('LoginRequest') do |request|
            websocket.emit_message(
              'header' => { 'msgId' => 'login-response', 'inReplyToId' => request.dig('header', 'msgId') },
              'payloadType' => 'LoginResponse',
              'payload' => { 'sessionId' => 'management-session' }
            )
          end
          websocket.on_send('GetDeviceInformationRequest') do |request|
            websocket.emit_message(
              'header' => { 'msgId' => 'info-response', 'inReplyToId' => request.dig('header', 'msgId') },
              'payloadType' => 'GetDeviceInformationResponse',
              'payload' => { 'providerId' => 'DECHY', 'productShortName' => 'ST1506', 'deviceName' => 'Cherry' }
            )
          end
          websocket.on_send('LogoutRequest') do
            websocket.emit_message(
              'header' => { 'msgId' => 'logout-response' },
              'payloadType' => 'LogoutResponse',
              'payload' => {}
            )
          end

          result = with_env('DEFAULT_WS_AUTH_PASS' => 'secret') { service.get_info }

          expect(result).to be_success
          expect(result.message).to eq('Device information received')
          expect(result.value).to be_a(CherryV1::Info)
          expect(result.value.identification).to eq('DECHY-ST1506')
          expect(websocket.sent_payload_types).to eq(%w[LoginRequest GetDeviceInformationRequest LogoutRequest])
          expect(websocket.close_count).to eq(1)
        end

        it 'preserves successful device information when cleanup logout JSON is malformed' do
          websocket.on_send('LoginRequest') do |request|
            websocket.emit_message(
              'header' => { 'msgId' => 'login-response', 'inReplyToId' => request.dig('header', 'msgId') },
              'payloadType' => 'LoginResponse',
              'payload' => { 'sessionId' => 'management-session' }
            )
          end
          websocket.on_send('GetDeviceInformationRequest') do |request|
            websocket.emit_message(
              'header' => { 'msgId' => 'info-response', 'inReplyToId' => request.dig('header', 'msgId') },
              'payloadType' => 'GetDeviceInformationResponse',
              'payload' => { 'providerId' => 'DECHY', 'productShortName' => 'ST1506', 'deviceName' => 'Cherry' }
            )
          end
          websocket.on_send('LogoutRequest') { websocket.emit_raw('{not-json') }

          result = with_env('DEFAULT_WS_AUTH_PASS' => 'secret') { service.get_info }

          expect(result).to be_success
          expect(result.message).to eq('Device information received')
          expect(result.value).to be_a(CherryV1::Info)
          expect(result.value.identification).to eq('DECHY-ST1506')
          expect(websocket.sent_payload_types).to eq(%w[LoginRequest GetDeviceInformationRequest LogoutRequest])
          expect(websocket.close_count).to eq(1)
        end

        it 'fails fast when a LoginRequest receives a successful non-login payload with a session id' do
          websocket.on_send('LoginRequest') do |request|
            websocket.emit_message(
              'header' => { 'msgId' => 'unexpected-response', 'inReplyToId' => request.dig('header', 'msgId') },
              'payloadType' => 'GetDeviceInformationResponse',
              'payload' => { 'sessionId' => 'management-session', 'deviceName' => 'Cherry' }
            )
          end
          websocket.on_send('GetDeviceInformationRequest') { raise 'unexpected GetDeviceInformationRequest' }

          result = with_env('DEFAULT_WS_AUTH_PASS' => 'secret') { service.get_info }

          expect(result).not_to be_success
          expect(result.message).to eq('Unexpected ST-1506 management response for LoginRequest: GetDeviceInformationResponse')
          expect(websocket.sent_payload_types).to eq(%w[LoginRequest])
          expect(websocket.close_count).to eq(1)
        end

        it 'logs out best-effort after a post-login device-information error' do
          websocket.on_send('LoginRequest') do |request|
            websocket.emit_message(
              'header' => { 'msgId' => 'login-response', 'inReplyToId' => request.dig('header', 'msgId') },
              'payloadType' => 'LoginResponse',
              'payload' => { 'sessionId' => 'management-session' }
            )
          end
          websocket.on_send('GetDeviceInformationRequest') do |request|
            websocket.emit_message(
              'header' => { 'msgId' => 'info-response', 'inReplyToId' => request.dig('header', 'msgId') },
              'payloadType' => 'GetDeviceInformationResponse',
              'payload' => { 'error' => 'Internal error' }
            )
          end
          websocket.on_send('LogoutRequest') { websocket.close }

          result = with_env('DEFAULT_WS_AUTH_PASS' => 'secret') { service.get_info }

          expect(result).not_to be_success
          expect(result.message).to eq('Internal error')
          expect(websocket.sent_payload_types).to eq(%w[LoginRequest GetDeviceInformationRequest LogoutRequest])
          expect(websocket.close_count).to eq(1)
        end

        it 'fails fast and closes on a successful response with missing inReplyToId before login' do
          websocket.on_send('LoginRequest') do
            websocket.emit_message(
              'header' => { 'msgId' => 'login-response' },
              'payloadType' => 'LoginResponse',
              'payload' => { 'sessionId' => 'management-session' }
            )
          end

          result = with_env('DEFAULT_WS_AUTH_PASS' => 'secret') { service.get_info }

          expect(result).not_to be_success
          expect(result.message).to match(/unknown inReplyToId \(missing\)/)
          expect(websocket.sent_payload_types).to eq(%w[LoginRequest])
          expect(websocket.close_count).to eq(1)
        end

        it 'preserves a post-login protocol failure message when logout hangs until timeout' do
          allow(EM::Timer).to receive(:new) do |_seconds, &block|
            @timer_callback = block
            timer
          end
          websocket.on_send('LoginRequest') do |request|
            websocket.emit_message(
              'header' => { 'msgId' => 'login-response', 'inReplyToId' => request.dig('header', 'msgId') },
              'payloadType' => 'LoginResponse',
              'payload' => { 'sessionId' => 'management-session' }
            )
          end
          websocket.on_send('GetDeviceInformationRequest') do
            websocket.emit_message(
              'header' => { 'msgId' => 'info-response', 'inReplyToId' => 'unknown-request-id' },
              'payloadType' => 'GetDeviceInformationResponse',
              'payload' => { 'deviceName' => 'Cherry' }
            )
          end
          websocket.on_send('LogoutRequest') { @timer_callback.call }

          result = with_env('DEFAULT_WS_AUTH_PASS' => 'secret') { service.get_info }

          expect(result).not_to be_success
          expect(result.message).to match(/unknown inReplyToId unknown-request-id/)
          expect(result.message).not_to eq('Timeout while requesting device information')
          expect(websocket.sent_payload_types).to eq(%w[LoginRequest GetDeviceInformationRequest LogoutRequest])
          expect(websocket.close_count).to eq(1)
        end

        it 'fails fast and logs out after login on a successful response with unknown inReplyToId' do
          websocket.on_send('LoginRequest') do |request|
            websocket.emit_message(
              'header' => { 'msgId' => 'login-response', 'inReplyToId' => request.dig('header', 'msgId') },
              'payloadType' => 'LoginResponse',
              'payload' => { 'sessionId' => 'management-session' }
            )
          end
          websocket.on_send('GetDeviceInformationRequest') do
            websocket.emit_message(
              'header' => { 'msgId' => 'info-response', 'inReplyToId' => 'unknown-request-id' },
              'payloadType' => 'GetDeviceInformationResponse',
              'payload' => { 'deviceName' => 'Cherry' }
            )
          end
          websocket.on_send('LogoutRequest') { websocket.close }

          result = with_env('DEFAULT_WS_AUTH_PASS' => 'secret') { service.get_info }

          expect(result).not_to be_success
          expect(result.message).to match(/unknown inReplyToId unknown-request-id/)
          expect(websocket.sent_payload_types).to eq(%w[LoginRequest GetDeviceInformationRequest LogoutRequest])
          expect(websocket.close_count).to eq(1)
        end

        it 'fails fast and logs out on an unexpected successful payload for the pending request' do
          websocket.on_send('LoginRequest') do |request|
            websocket.emit_message(
              'header' => { 'msgId' => 'login-response', 'inReplyToId' => request.dig('header', 'msgId') },
              'payloadType' => 'LoginResponse',
              'payload' => { 'sessionId' => 'management-session' }
            )
          end
          websocket.on_send('GetDeviceInformationRequest') do |request|
            websocket.emit_message(
              'header' => { 'msgId' => 'unexpected-response', 'inReplyToId' => request.dig('header', 'msgId') },
              'payloadType' => 'LoginResponse',
              'payload' => { 'sessionId' => 'other-session' }
            )
          end
          websocket.on_send('LogoutRequest') { websocket.close }

          result = with_env('DEFAULT_WS_AUTH_PASS' => 'secret') { service.get_info }

          expect(result).not_to be_success
          expect(result.message).to eq('Unexpected ST-1506 management response for GetDeviceInformationRequest: LoginResponse')
          expect(websocket.sent_payload_types).to eq(%w[LoginRequest GetDeviceInformationRequest LogoutRequest])
          expect(websocket.close_count).to eq(1)
        end

        it 'fails and closes on malformed management JSON' do
          websocket.on_send('LoginRequest') { websocket.emit_raw('{not-json') }

          result = with_env('DEFAULT_WS_AUTH_PASS' => 'secret') { service.get_info }

          expect(result).not_to be_success
          expect(result.message).to match(/Invalid JSON from ST-1506/)
          expect(websocket.sent_payload_types).to eq(%w[LoginRequest])
          expect(websocket.close_count).to eq(1)
        end

        class FakeManagementWebSocket
          attr_reader :close_count, :handlers, :sent

          def initialize
            @close_count = 0
            @handlers = {}
            @sent = []
            @send_handlers = {}
          end

          def on(event, &block)
            handlers[event] = block
          end

          def send(message)
            request = JSON.parse(message)
            sent << request
            @send_handlers.fetch(request['payloadType']).call(request)
          end

          def close
            @close_count += 1
            handlers[:close]&.call(OpenStruct.new(code: 1000, reason: 'closed'))
          end

          def emit_open
            handlers.fetch(:open).call(OpenStruct.new)
          end

          def emit_message(message)
            emit_raw(message.to_json)
          end

          def emit_raw(data)
            handlers.fetch(:message).call(OpenStruct.new(data: data))
          end

          def on_send(payload_type, &block)
            @send_handlers[payload_type] = block
          end

          def sent_payload_types
            sent.map { |request| request['payloadType'] }
          end
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

          instrumented_mutex = Class.new do
            attr_reader :waiting_for_lock

            def initialize
              @mutex = Mutex.new
              @state_mutex = Mutex.new
              @locked = false
              @waiting_for_lock = Queue.new
            end

            def synchronize
              waiting_for_lock << true if locked?

              @mutex.synchronize do
                @state_mutex.synchronize { @locked = true }
                begin
                  yield
                ensure
                  @state_mutex.synchronize { @locked = false }
                end
              end
            end

            def locked?
              @state_mutex.synchronize { @locked }
            end
          end.new
          allow(described_class).to receive(:terminal_mutex_for).and_return(instrumented_mutex)

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
          expect(pop_with_timeout.call(instrumented_mutex.waiting_for_lock)).to be(true)
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

      describe '#verify_pin_while' do
        let(:card_terminal) { FactoryBot.create(:card_terminal, :with_mac, ip: '192.0.2.10') }
        let(:service) { described_class.new(card_terminal: card_terminal) }
        let(:key_result) { described_class::Result.new(success?: true, message: 'key', value: 'a' * 64) }

        before do
          allow(card_terminal).to receive(:rmi_port).and_return(8443)
          allow(card_terminal).to receive(:tcp_port_open?).with(8443).and_return(true)
        end

        it 'validates the card slot and SMC-B key before starting the block listener' do
          slot = FactoryBot.create(:card_terminal_slot, card_terminal: card_terminal, slotid: 2)
          FactoryBot.create(:card, iccsn: '802760000000000004', card_terminal_slot: slot)
          block_called = false

          with_env('DEFAULT_SMCB_PIN' => '123456', 'DEFAULT_WS_AUTH_PASS' => 'secret') do
            expect(service).to receive(:fetch_smcb_authentication_key).and_return(key_result)
            expect(service).to receive(:connect_remote_smcb_api_while).with('a' * 64, 2).and_return(described_class::Result.new(success?: true, message: 'ok'))

            result = service.verify_pin_while('802760000000000004') { block_called = true }

            expect(result).to be_success
            expect(block_called).to be(false)
          end
        end

        it 'fails before fetching an SMC-B key when the ICCSN does not belong to this terminal' do
          with_env('DEFAULT_SMCB_PIN' => '123456', 'DEFAULT_WS_AUTH_PASS' => 'secret') do
            expect(service).not_to receive(:fetch_smcb_authentication_key)
            expect(service).not_to receive(:connect_remote_smcb_api_while)

            result = service.verify_pin_while('802760000000000099') { raise 'should not run' }

            expect(result).not_to be_success
            expect(result.message).to match(/not assigned|ICCSN/)
          end
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

      describe '#connect_remote_smcb_api_while' do
        let(:card_terminal) { instance_double(CardTerminal, id: 1, ip: '192.0.2.10', rmi_port: 8443) }
        let(:service) { described_class.new(card_terminal: card_terminal) }
        let(:websocket) { FakeBlockWebSocket.new }
        let(:key) { 'a' * 64 }
        let(:timer) { instance_double(EM::Timer, cancel: true) }

        before do
          allow(Faye::WebSocket::Client).to receive(:new).and_return(websocket)
          allow(EM::Timer).to receive(:new) do |_seconds, &block|
            @timeout_callback = block
            timer
          end
          allow(EM).to receive(:stop)
          allow(EM).to receive(:reactor_running?).and_return(false)
          allow(EM).to receive(:run) do |&block|
            block.call
            @exercise_websocket.call
          end
          allow(service).to receive(:toaster)
        end

        it 'runs the caller block only after SMC-B authentication, answers multiple authorized PIN requests, and returns the block value' do
          block_started = Queue.new
          release_block = Queue.new
          events = []

          @exercise_websocket = lambda do
            expect(events).to be_empty
            websocket.emit_message(authenticate_request)
            expect(Timeout.timeout(1) { block_started.pop }).to eq(:started)
            expect(websocket.sent_payload_types).to include('AuthenticateResponse')

            websocket.emit_message(input_pin_request('pin-1', 'Slot1'))
            websocket.emit_message(success_notify('notify-1'))
            websocket.emit_message(input_pin_request('pin-2', 'Slot1'))
            websocket.emit_message(success_notify('notify-2'))
            release_block << true
          end

          result = with_env('DEFAULT_SMCB_PIN' => '123456') do
            service.send(:connect_remote_smcb_api_while, key, 1) do
              events << :block
              block_started << :started
              release_block.pop
              :block_result
            end
          end

          expect(events).to eq([:block])
          expect(websocket.sent_payload_types.count('InputPinResponse')).to eq(2)
          expect(websocket.close_count).to eq(1)
          expect(result).to be_success
          expect(result.value).to eq(:block_result)
        end

        it 'keeps the listener open after the block until pending PIN notify confirmations arrive' do
          block_started = Queue.new
          release_block = Queue.new

          @exercise_websocket = lambda do
            websocket.emit_message(authenticate_request)
            Timeout.timeout(1) { block_started.pop }
            websocket.emit_message(input_pin_request('pin-1', 'Slot1'))
            release_block << true
            sleep 0.05
            expect(websocket.close_count).to eq(0)

            websocket.emit_message(success_notify('notify-1'))
          end

          result = with_env('DEFAULT_SMCB_PIN' => '123456') do
            service.send(:connect_remote_smcb_api_while, key, 1) do
              block_started << true
              release_block.pop
            end
          end

          expect(websocket.close_count).to eq(1)
          expect(result).to be_success
        end

        it 'fails via the pending notify timeout when an authenticated PIN request is never confirmed' do
          block_started = Queue.new
          release_block = Queue.new

          allow(service).to receive(:smcb_idle_timeout_seconds).and_return(0.01)

          @exercise_websocket = lambda do
            websocket.emit_message(authenticate_request)
            Timeout.timeout(1) { block_started.pop }
            websocket.emit_message(input_pin_request('pin-1', 'Slot1'))
            release_block << true
            @timeout_callback.call
          end

          result = with_env('DEFAULT_SMCB_PIN' => '123456') do
            service.send(:connect_remote_smcb_api_while, key, 1) do
              block_started << true
              release_block.pop
              :block_result
            end
          end

          expect(websocket.sent_payload_types).to include('InputPinResponse')
          expect(websocket.close_count).to eq(1)
          expect(result).not_to be_success
          expect(result.message).to eq('Timeout waiting for ST-1506 PIN notify completion')
        end

        it 'rejects wrong-slot PIN requests and closes without sending the PIN' do
          @exercise_websocket = lambda do
            websocket.emit_message(authenticate_request)
            websocket.emit_message(input_pin_request('pin-1', 'Slot2'))
          end

          result = with_env('DEFAULT_SMCB_PIN' => '123456') do
            service.send(:connect_remote_smcb_api_while, key, 1) { sleep 0.01 }
          end

          expect(websocket.sent_payload_types).not_to include('InputPinResponse')
          expect(websocket.close_count).to eq(1)
          expect(result).not_to be_success
          expect(result.message).to match(/not authorized/)
        end

        it 'waits for the caller block to finish before returning after a wrong-slot failure' do
          block_started = Queue.new
          release_block = Queue.new
          block_finished = Queue.new
          returned = Queue.new

          @exercise_websocket = lambda do
            websocket.emit_message(authenticate_request)
            Timeout.timeout(1) { block_started.pop }
            websocket.emit_message(input_pin_request('pin-1', 'Slot2'))
          end

          thread = Thread.new do
            result = with_env('DEFAULT_SMCB_PIN' => '123456') do
              service.send(:connect_remote_smcb_api_while, key, 1) do
                block_started << true
                release_block.pop
                block_finished << true
              end
            end
            returned << result
            result
          end

          sleep 0.2
          expect(returned).to be_empty

          release_block << true
          result = Timeout.timeout(1) { returned.pop }

          expect(Timeout.timeout(1) { block_finished.pop }).to be(true)
          expect(result).not_to be_success
          expect(result.message).to match(/not authorized/)
          expect(thread.value).to eq(result)
        ensure
          release_block << true if defined?(release_block)
          thread&.join(1)
        end

        it 'fails without running the caller block when the auth timer fires before authentication' do
          @exercise_websocket = lambda do
            @timeout_callback.call
          end

          result = with_env('DEFAULT_SMCB_PIN' => '123456') do
            service.send(:connect_remote_smcb_api_while, key, 1) { raise 'should not run' }
          end

          expect(result).not_to be_success
          expect(result.message).to eq('Timeout during ST-1506 block PIN verification')
        end

        it 'preserves a pre-auth timeout result when listener shutdown join times out' do
          allow(service).to receive(:smcb_total_timeout_seconds).and_return(0.01)
          join_calls = 0
          allow(Thread).to receive(:new).and_wrap_original do |original, *args, &thread_block|
            thread = original.call(*args, &thread_block)
            allow(thread).to receive(:join) do |_timeout = nil|
              join_calls += 1
              join_calls == 1 ? nil : true
            end
            allow(thread).to receive(:kill).and_return(thread)
            thread
          end

          @exercise_websocket = lambda do
            @timeout_callback.call
          end

          result = with_env('DEFAULT_SMCB_PIN' => '123456') do
            service.send(:connect_remote_smcb_api_while, key, 1) { raise 'should not run' }
          end

          expect(result).not_to be_success
          expect(result.message).to eq('Timeout during ST-1506 block PIN verification')
        end

        it 'does not spend the auth timeout while waiting for the EventMachine lock' do
          allow(service).to receive(:smcb_total_timeout_seconds).and_return(0.02)
          allow(described_class).to receive(:with_eventmachine_lock) do |&block|
            expect(Faye::WebSocket::Client).not_to have_received(:new)
            sleep 0.06
            block.call
          end

          @exercise_websocket = lambda do
            websocket.emit_message(authenticate_request)
          end

          result = with_env('DEFAULT_SMCB_PIN' => '123456') do
            service.send(:connect_remote_smcb_api_while, key, 1) { :after_auth }
          end

          expect(Faye::WebSocket::Client).to have_received(:new).once
          expect(websocket.close_count).to eq(1)
          expect(result).to be_success
          expect(result.value).to eq(:after_auth)
        end

        it 'does not stop another active reactor when startup times out before this listener starts' do
          blocked_listener = Queue.new

          allow(service).to receive(:smcb_total_timeout_seconds).and_return(0.01)
          allow(EM).to receive(:reactor_running?).and_return(true)
          expect(EM).not_to receive(:schedule)
          expect(EM).not_to receive(:stop)
          expect(Faye::WebSocket::Client).not_to receive(:new)
          allow(described_class).to receive(:with_eventmachine_lock) do
            blocked_listener.pop
          end

          result = with_env('DEFAULT_SMCB_PIN' => '123456') do
            service.send(:connect_remote_smcb_api_while, key, 1) { raise 'should not run' }
          end

          expect(websocket.close_count).to eq(0)
          expect(result).not_to be_success
          expect(result.message).to eq('Timeout stopping ST-1506 block PIN verification listener')
        ensure
          blocked_listener << true if defined?(blocked_listener)
        end

        it 'ignores the auth timer after authentication while a slow caller block is running' do
          block_started = Queue.new
          block_finished = Queue.new

          allow(service).to receive(:smcb_total_timeout_seconds).and_return(0.01)
          @exercise_websocket = lambda do
            websocket.emit_message(authenticate_request)
            Timeout.timeout(1) { block_started.pop }
            @timeout_callback.call
          end

          result = with_env('DEFAULT_SMCB_PIN' => '123456') do
            service.send(:connect_remote_smcb_api_while, key, 1) do
              block_started << true
              sleep 0.05
              block_finished << true
              :slow_block_result
            end
          end

          expect(timer).to have_received(:cancel)
          expect(Timeout.timeout(1) { block_finished.pop }).to be(true)
          expect(websocket.close_count).to eq(1)
          expect(result).to be_success
          expect(result.value).to eq(:slow_block_result)
        end

        it 'runs listener thread callbacks and the caller block through the Rails executor' do
          block_started = Queue.new
          release_block = Queue.new
          listener_callback_wrapped = Queue.new
          caller_wrapped = Queue.new
          executor = Class.new do
            def wrap
              previous = Thread.current[:cherry_v1_executor_wrapped]
              Thread.current[:cherry_v1_executor_wrapped] = true
              yield
            ensure
              Thread.current[:cherry_v1_executor_wrapped] = previous
            end
          end.new

          allow(Rails).to receive(:application).and_return(double('Rails application', executor: executor))
          expect(service).to receive(:toaster) do
            listener_callback_wrapped << Thread.current[:cherry_v1_executor_wrapped]
          end

          @exercise_websocket = lambda do
            websocket.emit_message(authenticate_request)
            Timeout.timeout(1) { block_started.pop }
            websocket.emit_message(input_pin_request('pin-1', 'Slot1'))
            websocket.emit_message(success_notify('notify-1'))
            release_block << true
          end

          result = with_env('DEFAULT_SMCB_PIN' => '123456') do
            service.send(:connect_remote_smcb_api_while, key, 1) do
              caller_wrapped << Thread.current[:cherry_v1_executor_wrapped]
              block_started << true
              release_block.pop
              :executor_wrapped
            end
          end

          expect(Timeout.timeout(1) { listener_callback_wrapped.pop }).to be(true)
          expect(Timeout.timeout(1) { caller_wrapped.pop }).to be(true)
          expect(result).to be_success
          expect(result.value).to eq(:executor_wrapped)
        end

        it 'converts block errors to a failure and closes the listener' do
          @exercise_websocket = lambda do
            websocket.emit_message(authenticate_request)
            sleep 0.05
          end

          result = with_env('DEFAULT_SMCB_PIN' => '123456') do
            service.send(:connect_remote_smcb_api_while, key, 1) { raise 'connector failed' }
          end

          expect(websocket.close_count).to eq(1)
          expect(result).not_to be_success
          expect(result.message).to match(/connector failed/)
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

        class FakeBlockWebSocket
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

          def sent_payload_types
            sent.map { |message| JSON.parse(message)['PayloadType'] }
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
