module RISE
  module TIClient
    class RemotePinPlus::Card

      def initialize(hash)
        @json = hash || {}
      end

      def iccsn
       @json.dig('card', 'iccsn') 
      end

      def card_holder
       @json.dig('card', 'cardHolder')
      end

      def terminal_id
       @json.dig('card', 'terminalId')
      end

      def terminal_name
       @json.dig('card', 'terminalHostname')
      end

      def card_type
       @json.dig('card', 'cardType') 
      end

      def state
       @json.dig('status')  || @json.dig('state')
      end


    end
  end
end
