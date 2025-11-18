module RISE
  module TIClient
    class Token
      attr_reader :scope, :token_type, :valid_until

      def initialize(json_string)
        @json = begin JSON.parse(json_string) rescue {} end
        @scope = json['scope']
        @token_type = json['token_type']
        @valid_until = set_expiration
      end

      def token
        if valid?
          json['access_token']
        else
          nil
        end
      end

      def valid?
        Time.current <= valid_until
      end

    private
      attr_reader :json

      def set_expiration
        expires_in = (json['expires_in'].to_i) - 30
        expires_in.seconds.after(Time.current)
      end

    end
  end
end
