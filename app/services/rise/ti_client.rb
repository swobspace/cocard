module RISE
  class TIClient
    attr_reader :ti_client, :errors

    def initialize(options = {})
      options = options.symbolize_keys
      @ti_client = options.fetch(:ti_client)
      @errors = []
    end

    def get_card_terminal_proxies
      @errors = []
      token = api_token
      if token.nil?
        return nil
      end
      begin
        response = connection.get('/api/v1/manager/card-terminals/proxies',
                     {},
                     { 'Content-Type': 'application/json',
                       'authorization': "Bearer #{token}" }
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
      json = JSON.parse(response.body)
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
                     client_id: ENV['TIC_APP'],
                     client_secret: ENV['TIC_SECRET'],
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

  private
    def connection
      @connection ||= Faraday.new(faraday_options.merge(tls_options))
    end

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
