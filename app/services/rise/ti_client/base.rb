module RISE
  class TIClient::Base
    attr_reader :ti_client, :errors

    def initialize(options = {})
      options = options.symbolize_keys
      @ti_client = options.fetch(:ti_client)
      @errors = []
    end

    def api_token
      authorization&.token
    end

    def authorization
      if @authorization.present? && @authorization.valid?
        @authorization
      else
        @authorization = authenticate
      end
    end

    def authenticate
      @errors = []
      begin
        response = connection.post('/oauth2/token', 
                     client_id: ti_client.client_id,
                     client_secret: ti_client.client_secret,
                     scope: 'API',
                     grant_type: 'client_credentials'
                   )
        unless response.success?
          @errors << "#{response.status}: #{response.body}"
          return nil
        end
      rescue Faraday::Error => e
        err = []
        err << e.response_status
        err << e.response_headers
        err << e.response_body
        err << e.message
        err.compact!
        @errors << err.join("; ")
        return nil
      end
      token = RISE::TIClient::Token.new(response.body)
    end

  protected

    def connection
      @connection ||= Faraday.new(faraday_options.merge(tls_options))
    end

    def faraday_error(e)
      err = []
      err << e.response_status
      err << e.response_headers
      err << e.response_body
      err << e.message
      err.compact!
      err.join("; ")
    end

    def ssl_verify_none
      ctx = OpenSSL::SSL::SSLContext.new
      ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
      ctx
    end

  private

    def tls_options
      { ssl:{ verify: false } }
    end
        
    def faraday_options
      { 
        request: { open_timeout: 15, timeout: 30 },
        url: uri_base
      }  
    end   

    def uri_base
      ti_client.url
    end


  end
end
