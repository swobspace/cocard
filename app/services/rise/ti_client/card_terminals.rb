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
          @errors << faraday_error(e)
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
      uuid = kt_proxy.uuid
      token = api_token
      if token.nil?
        @errors << "Authentifikation fehlgeschlagen"
      else
        @errors = []
        begin
          response = connection.get("/api/v1/manager/card-terminals/proxies/#{uuid}",
                       {},
                       { 'Content-Type': 'application/json',
                         'authorization': "Bearer #{token}" }
                     )
          unless response.success?
            @errors << "#{response.status}: #{response.body}"
          end
        rescue Faraday::Error => e
          @errors << faraday_error(e)
        end
      end

      if response.status == 404
        yield RISE::TIClient::Status.notfound(@errors.join("; "))
      elsif @errors.any?
        yield RISE::TIClient::Status.failure(@errors.join("; "))
      else
        json = JSON.parse(response.body)
        yield RISE::TIClient::Status.success("#{response.status}: Success", json)
      end
    end

    def create_proxy(kt_proxy)
      token = api_token
      if token.nil?
        @errors << "Authentifikation fehlgeschlagen"
      else
        @errors = []
        begin
          response = connection.post("/api/v1/manager/card-terminals/proxies",
                       kt_proxy.to_builder.target!,
                       { 'Content-Type': 'application/json',
                         'authorization': "Bearer #{token}" }
                     )
          unless response.success?
            @errors << "#{response.status}: #{response.body}"
          end
        rescue Faraday::Error => e
          @errors << faraday_error(e)
        end
      end

      if @errors.any?
        yield RISE::TIClient::Status.failure(@errors.join("; "))
      else
        json = JSON.parse(response.body)
        yield RISE::TIClient::Status.success("#{response.status}: Success", json)
      end
    end

    def update_proxy(kt_proxy)
      uuid = kt_proxy.uuid
      token = api_token
      if token.nil?
        @errors << "Authentifikation fehlgeschlagen"
      else
        @errors = []
        begin
          response = connection.post("/api/v1/manager/card-terminals/proxies/#{uuid}",
                       kt_proxy.to_builder.target!,
                       { 'Content-Type': 'application/json',
                         'authorization': "Bearer #{token}" }
                     )
          unless response.success?
            @errors << "#{response.status}: #{response.body}"
          end
        rescue Faraday::Error => e
          @errors << faraday_error(e)
        end
      end

      if response.status == 404
        yield RISE::TIClient::Status.notfound(@errors.join("; "))
      elsif @errors.any?
        yield RISE::TIClient::Status.failure(@errors.join("; "))
      else
        yield RISE::TIClient::Status.success("#{response.status}: Success")
      end
    end

    def destroy_proxy(kt_proxy)
    end
  end
end
