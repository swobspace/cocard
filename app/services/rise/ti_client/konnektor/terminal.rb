module RISE
  module TIClient
    module Konnektor
      class Terminal

        def initialize(hash)
          @json = hash || {}
        end

        def correlation
          @json['CORRELATION']
        end

        def mac
          @json['MAC_ADDRESS']
        end

        def ct_id
          @json['CTID']
        end

        def name
          @json['HOSTNAME']
        end

      end
    end
  end
end
