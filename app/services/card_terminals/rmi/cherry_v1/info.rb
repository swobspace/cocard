module CardTerminals
  class RMI
    class CherryV1::Info
      ATTRIBUTES = %i[
        terminalname
        dhcp_enabled
        macaddr
        current_ip
        static_ip
        dhcp_ip
        remote_pin_enabled
        remote_pairing_enabled
        ntp_enabled
        ntp_server
        tftp_server
        tftp_file
        firmware_version
        firmware_builddate
        serial
        uptime_total
        uptime_reboot
        slot1_plug_cycles
        slot2_plug_cycles
        slot3_plug_cycles
        slot4_plug_cycles
        identification
        smckt_iccsn
        smckt_version
        smckt_slot
        smckt_auth1_type
        smckt_auth1_expiration
        smckt_auth2_type
        smckt_auth2_expiration
        tls_kt_ecgroup
        tls_kt_pubkey_algo
        tls_konn_ecgroup
        tls_konn_pubkey_algo
      ]

      def initialize(properties)
        @properties = properties || {}
      end

      def terminalname
        properties['deviceName'] || properties[:deviceName]
      end

      def dhcp_enabled
        explicit = property('useDhcp')
        return explicit unless explicit.nil?

        case property('networkMode')
        when 'Dhcp'
          true
        when 'StaticIp', 'Rfc3927'
          false
        end
      end

      def macaddr
        property('ethernetMacAddress').to_s.delete(':').upcase.presence
      end

      def current_ip
        property('ipAddress')
      end

      def static_ip
        current_ip if property('networkMode') == 'StaticIp'
      end

      def dhcp_ip
        current_ip if dhcp_enabled
      end

      def remote_pin_enabled
        %w[remotepin1 remotepin2 remotepin3 remotepin4].any? { |key| property(key).to_i.positive? }
      end

      def remote_pairing_enabled
        nil
      end

      def ntp_enabled
        property('ntpSyncStatus') == 'synced' || property('ntpSyncServer').present?
      end

      def ntp_server
        property('ntpSyncServer')
      end

      def tftp_server
        nil
      end

      def tftp_file
        nil
      end

      def firmware_version
        property('fwVersion')
      end

      def build_version
        property('buildVersion')
      end

      def firmware_builddate
        nil
      end

      def serial
        nil
      end

      def uptime_total
        nil
      end

      def uptime_reboot
        nil
      end

      def slot1_plug_cycles
        nil
      end

      def slot2_plug_cycles
        nil
      end

      def slot3_plug_cycles
        nil
      end

      def slot4_plug_cycles
        nil
      end

      def identification
        [property('providerId'), product_code].compact_blank.join('-').presence
      end

      # ST-1506 exposes smcktSerialNumber, but the protocol field is not a
      # Cocard ICCSN. Keep it available as a Cherry-specific value instead of
      # creating/linking an SMC-KT card from an unsupported identifier.
      def smckt_iccsn
        nil
      end

      def smckt_serial_number
        property('smcktSerialNumber')
      end

      def smckt_version
        property('smcktProductTypeVersion')
      end

      # The ST-1506 device-information payload does not expose an SMC-KT slot.
      # Return zero so downstream code treats the slot as unavailable.
      def smckt_slot
        0
      end

      # smcktPersonalization documents the SMC-KT personalization algorithms
      # (for example RSA, ECC, or RSA,ECC), not the same semantics as Cocard's
      # AUT/AUT2 type fields. Do not overload it into auth*_type.
      def smckt_personalization
        property('smcktPersonalization')
      end

      def smckt_auth1_type
        nil
      end

      def smckt_auth1_expiration
        parse_yyyymmdd(property('smcktExpirationDateAUT'))
      end

      def smckt_auth2_type
        nil
      end

      def smckt_auth2_expiration
        parse_yyyymmdd(property('smcktExpirationDateAUT2'))
      end

      def smckt_autd_expiration
        parse_yyyymmdd(property('smcktExpirationDateAUTD'))
      end

      def tls_kt_ecgroup
        nil
      end

      def tls_kt_pubkey_algo
        nil
      end

      def tls_konn_ecgroup
        nil
      end

      def tls_konn_pubkey_algo
        nil
      end

      def preserve_nil_terminal_attributes?
        true
      end

      def missing_smckt_card_is_success?
        true
      end

    private
      attr_reader :properties

      def product_code
        property('productShortName').presence || property('productType')
      end

      def property(key)
        return properties[key] if properties.key?(key)
        return properties[key.to_sym] if properties.key?(key.to_sym)

        nil
      end

      def parse_yyyymmdd(value)
        value = value.to_s
        return nil if value.blank?

        Date.strptime(value, '%Y%m%d')
      rescue ArgumentError
        nil
      end
    end
  end
end
