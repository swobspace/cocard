module CardTerminals
  class RMI
    #
    # Base class
    #
    class Base
      RMIResult = ImmutableStruct.new(:success?, :response)

      attr_reader :card_terminal, :messages, :result
      #
      # mandantory options:
      # * :card_terminal - card_terminal object
      #
      def initialize(options = {})
        options = options.symbolize_keys
        @card_terminal = options.fetch(:card_terminal)
        @messages = []
        @session = {}
        @result = {}
        @logger = ActiveSupport::Logger.new(
                    File.join(Rails.root, 'log', 'card_terminals_rmi.log')
                  )
      end

      def available_actions
        []
      end

      def rmi_port
        443
      end

      def supported?
        false
      end

      def firmware_version
        card_terminal.firmware_version
      end

    private
      attr_reader :session, :logger
    end
  end
end
