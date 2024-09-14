module CardTerminals
  module RMI
    #
    # Remote Management Interface for Orga 6141 Version 1.03
    #
    class Base
      attr_reader :card_terminal, :valid, :messages, :rmi

      #
      # rmi = CardTerminal::RMI::Base.new(options)
      #
      # mandantory options:
      # * :card_terminal - card_terminal object
      #
      def initialize(options = {})
        options.symbolize_keys
        @card_terminal = options.fetch(:card_terminal)
        @valid, @rmi = check_terminal
        @messages = []
      end

    private

      def check_terminal
        if card_terminal.product_information&.product_code == "ORGA6100" &&
           card_terminal.firmware_version >= '3.9.0'
           [true, CardTerminals::RMI::OrgaV1]
        else
           [false, nil]
        end
      end

    end
  end
end
