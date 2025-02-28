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
        options = options.symbolize_keys
        @card_terminal = options.fetch(:card_terminal)
        @messages = []
        @valid, @rmi = check_terminal
      end

    private

      def check_terminal
        # if card_terminal.pin_mode == 'off'
        #   @messages << "CardTerminal pin mode == 'off', please check settings"
        #   return [false, nil]
        # end

        pc = card_terminal.product_information&.product_code
        fw = card_terminal.firmware_version
        if pc == "ORGA6100" && fw >= '3.9.0'
           [true, CardTerminals::RMI::OrgaV1]
        else
           @messages << "CardTerminal #{pc} with firmware #{fw} is not supported"
           [false, nil]
        end
      end

    end
  end
end
