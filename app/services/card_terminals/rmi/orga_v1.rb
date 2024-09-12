module CardTerminals
  module RMI
    #
    # Remote Management Interface for Orga 6141 Version 1.03
    #
    class OrgaV1
      attr_reader :card_terminal, :valid, :session, :connection

      #
      # rmi = CardTerminal::RMI::OrgaV1.new(options)
      #
      # mandantory options:
      # * :card_terminal - card_terminal object
      #
      def initialize(options = {})
        options.symbolize_keys
        @card_terminal = options.fetch(:card_terminal)
        @valid = check_terminal
        @session = nil
        @connection = create_connection
      end

      def get_api
        response = connection.get('/') do |req|
          req.body = {
                       "request": {
                         "token": SecureRandom.uuid.to_s,
                         "service": "Api",
                         "method": {
                             "getVersionInfo": {}
                         }
                       }
                     }.to_json
        end
      end

    private
      def check_terminal
        card_terminal.product_information&.product_code == "ORGA6100" &&
        card_terminal.firmware_version >= '3.9.0'
      end

      def create_connection
        conn = Faraday.new(
                 url: 'https://' + card_terminal.ip.to_s,
                 request: { open_timeout: 15, timeout: 30 },
                 headers: {'Content-Type' => 'application/json'},
                 ssl: { verify: false }
               )
      end

    end
  end
end
