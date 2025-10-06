module CardTerminals
  class RMI       
    class OrgaV1::Info
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
      ]

      def initialize(properties)
        @properties = properties
      end

      def serial
        properties['vendor_serialNumber']
      end

      def firmware_version
        properties['sys_firmwareVersion']
      end

      def firmware_builddate
        properties['sys_firmwareBuildDate']
      end

      def terminalname
        properties['sys_terminalName']
      end

      def dhcp_enabled
        properties['net_lan_dhcpEnabled']
      end

      def macaddr
        unless properties['net_lan_macAddr'].nil?
          properties['net_lan_macAddr'].gsub(/:/, '').upcase 
        end
      end

      def current_ip
        properties['net_lan_ipAddr']
      end

      def static_ip
        properties['net_lan_ipAddrStatic']
      end

      def dhcp_ip
        properties['net_lan_ipAddrDhcp']
      end

      def remote_pin_enabled
        properties['rmi_smcb_pinEnabled']
      end

      def remote_pairing_enabled
        properties['rmi_pairingEHealthTerminal_enabled']
      end

      def tftp_server
        properties['update_serverIpAddr']
      end

      def tftp_file
        properties['update_fileName']
      end

      def ntp_server
        properties['sys_ntp_serverIpAddr']
      end

      def ntp_enabled
        properties['sys_ntp_enabled']
      end

  private
      attr_reader :properties
    end
  end
end
