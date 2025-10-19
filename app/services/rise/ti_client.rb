module RISE
  class TIClient
    attr_reader :ti_client

    def initialize(options = {})
      options = options.symbolize_keys
      @ti_client = options.fetch(:ti_client)
    end

    def api_token
      authorization.token
    end

    def authorization
      if @authorization.present? && @authorization.valid?
        @authorization
      else
        @authorization = authenticate
      end
    end

    def authenticate
      begin
        conn_options = faraday_options.merge(tls_options)
        conn = Faraday.new(conn_options)
        response = conn.post('/oauth2/token', 
                               client_id: ENV['TIC_APP'],
                               client_secret: ENV['TIC_SECRET'],
                               scope: 'API',
                               grant_type: 'client_credentials'
                            )
        unless response.success?
          # log something
          # return failure
          return nil
        end
      rescue Faraday::Error => e
        # log something
        # return failure
        return nil
      end
      token = RISE::TIClient::Token.new(response.body)
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
