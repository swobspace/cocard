module RISE
  class TIClient::CardTerminals < TIClient::Base
    def get_proxies
      token = api_token
      if token.nil?
        @errors << "Authentifikation fehlgeschlagen"
      else
        @errors = []
        begin
          response = connection.get('/api/v1/manager/card-terminals/proxies',
                       {},
                       { 'Content-Type': 'application/json',
                         'authorization': "Bearer #{token}" }
                     )
          unless response.success?
            @errors << "#{response.status}: #{response.body}"
          end
        rescue Faraday::Error => e
          err = []
          err << e.response_status
          err << e.response_headers
          err << e.response_body
          err << e.message
          err.compact!
          @errors << err.join("; ")
        end
      end
      if @errors.any?
        yield RISE::TIClient::Status.failure(@errors.join("; "))
      else
        json = JSON.parse(response.body)
        yield RISE::TIClient::Status.success("#{response.status}: Success", json)
      end
    end

    def get_proxy(kt_proxy)
    end

    def create_proxy(kt_proxy)
    end

    def update_proxy(kt_proxy)
    end

    def destroy_proxy(kt_proxy)
    end
  end
end
