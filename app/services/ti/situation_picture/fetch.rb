module TI
  module SituationPicture
    #
    # Fetch TI Lagebild json data
    #
    class Fetch
      attr_reader :hash
      Result = ImmutableStruct.new(:success?, :error_messages, :situation_picture)
      #
      # service = TI::SituationPicture::Fetch.new()
      #
      def initialize(options = {})
        options.symbolize_keys
        @json_array = []
        @situation_picture = []
      end

      # service.call()
      # do all the work here ;-)
      def call
        error_messages = []
        begin
          conn = Faraday.new(faraday_options)
          response = conn.get(lagebild_api)

          unless response.success?
            # error_messages << response.headers.join(' ')
            error_messages << response.status
            error_messages << response.body
            return Result.new(success?: false, error_messages: error_messages, situation_picture: nil)
          end
        rescue Faraday::Error => e
          error_messages << e.response_status
          error_messages << e.response_headers
          error_messages << e.response_body
          error_messages << e.message
          error_messages.compact!
          return Result.new(success?: false, error_messages: error_messages, situation_picture: nil)
        end

        @json_array = JSON.parse(response.body)
        @json_array.each do |entry|
          @situation_picture << TI::SinglePicture.new(entry)
        end
        Result.new(success?: true, error_messages: error_messages, situation_picture: @situation_picture)
      end

    private

      def faraday_options
        {
          request: { open_timeout: 15, timeout: 30 },
          ssl: {
            verify: false
          }
        }.merge(proxy_options)
      end

      def proxy_options
        if ENV['INTERNET_PROXY']
          { proxy: { uri: ENV['INTERNET_PROXY'] } }
        else
          {}
        end
      end

      def lagebild_api
        "https://ti-lage.prod.ccs.gematik.solutions/lageapi/v1/tilage/"
      end

    end
  end
end
