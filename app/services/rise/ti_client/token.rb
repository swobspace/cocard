module RISE
  class TIClient::Token
    attr_reader :scope, :token_type, :valid_until

    def initialize(json_string)
      @json = JSON.parse(json_string)
      @scope = json['scope']
      @token_type = json['token_type']
      @valid_until = set_expiration
    end

    def token
      if Time.current <= valid_until
        json['access_token']
      else
        nil
      end
    end

  private
    attr_reader :json

    def set_expiration
      expires_in = (json['expires_in'].to_i) - 30
      expires_in.seconds.after(Time.current)
    end

  end
end
