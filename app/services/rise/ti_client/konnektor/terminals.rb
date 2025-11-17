module RISE
  class TIClient::Konnektor::Terminals < TIClient::Base
    def get_terminals
      token = api_token
      if token.nil?
        @errors << "Authentifikation fehlgeschlagen"
      else
        @errors = []
        begin
          response = connection.get('/api/v1/konnektor/default/api/v1/ctm/state',
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

      if response.present? && response.status == 403
        yield RISE::TIClient::Status.access_denied(@errors.join("; "))
      elsif @errors.any?
        yield RISE::TIClient::Status.failure(@errors.join("; "))
      else
        json = JSON.parse(response.body)
        yield RISE::TIClient::Status.success("#{response.status}: Success", json)
      end
    end

    def get_terminal(ct_id)
      token = api_token
      if token.nil?
        @errors << "Authentifikation fehlgeschlagen"
      else
        @errors = []
        begin
          apiurl  = ti_client&.url
          apiurl += "/api/v1/konnektor/default/api/v1/ctm/state/#{ct_id}"
          response = HTTP.auth("Bearer #{token}")
                         .get(apiurl,
                              ssl_context: ssl_verify_none)
          unless response.status.success?
            @errors << "#{response.status.to_s}: #{response.body.to_s}"
          end
        rescue => e
          @errors << e.to_s
        end
      end

      if @errors.any?
        yield RISE::TIClient::Status.failure(@errors.join("; "))
      else
        json = JSON.parse(response.body)
        yield RISE::TIClient::Status.success("#{response.status}: Success", json)
      end
    end

    def discover
      token = api_token
      if token.nil?
        @errors << "Authentifikation fehlgeschlagen"
      else
        @errors = []
        begin
          response = HTTP.headers('Transfer-Encoding': 'chunked')
                         .auth("Bearer #{token}")
                         .post(ti_client.url +
                              '/api/v1/konnektor/default/api/v1/ctm/terminals/discover',
                              ssl_context: ssl_verify_none)
          unless response.status.success?
            @errors << "#{response.status.to_s}: #{response.body.to_s}"
          end
        rescue => e
          @errors << e.to_s
        end
      end

      if @errors.any?
        yield RISE::TIClient::Status.failure(@errors.join("; "))
      else
        yield RISE::TIClient::Status.success("#{response.status}: Success")
      end
    end

    def assign(ct_id)
      token = api_token
      if token.nil?
        @errors << "Authentifikation fehlgeschlagen"
      else
        @errors = []
        begin
          apiurl  = ti_client&.url
          apiurl += '/api/v1/konnektor/default/api/v1/ctm/terminals/assign'
          response = HTTP.headers('Transfer-Encoding': 'chunked')
                         .auth("Bearer #{token}")
                         .post(apiurl,
                              ssl_context: ssl_verify_none,
                              json: {"ctId": "#{ct_id}"})
          unless response.status.success?
            @errors << "#{response.status.to_s}: #{response.body.to_s}"
          end
        rescue => e
          @errors << e.to_s
        end
      end

      if @errors.any?
        yield RISE::TIClient::Status.failure(@errors.join("; "))
      else
        yield RISE::TIClient::Status.success("#{response.status}: Success")
      end
    end

    def initialize_pairing(ct_id)
      token = api_token
      if token.nil?
        @errors << "Authentifikation fehlgeschlagen"
      else
        @errors = []
        begin
          apiurl  = ti_client&.url
          apiurl += '/api/v1/konnektor/default/api/v1/ctm/terminals/pairing/initialize'
          response = HTTP.headers('Transfer-Encoding': 'chunked')
                         .auth("Bearer #{token}")
                         .post(apiurl,
                              ssl_context: ssl_verify_none,
                              json: {"ctId": "#{ct_id}"})
          unless response.status.success?
            @errors << "#{response.status.to_s}: #{response.body.to_s}"
          end
        rescue => e
          @errors << e.to_s
        end
      end

      if @errors.any?
        yield RISE::TIClient::Status.failure(@errors.join("; "))
      else
        json = JSON.parse(response.body)
        yield RISE::TIClient::Status.success("#{response.status}: Success", json)
      end
    end

    def finalize_pairing(session_data)
      token = api_token
      if token.nil?
        @errors << "Authentifikation fehlgeschlagen"
      else
        @errors = []
        begin
          apiurl  = ti_client&.url
          apiurl += '/api/v1/konnektor/default/api/v1/ctm/terminals/pairing/finalize'
          response = HTTP.headers('Transfer-Encoding': 'chunked')
                         .auth("Bearer #{token}")
                         .post(apiurl,
                              ssl_context: ssl_verify_none,
                              json: session_data)
          unless response.status.success?
            @errors << "#{response.status.to_s}: #{response.body.to_s}"
          end
        rescue => e
          @errors << e.to_s
        end
      end

      if @errors.any?
        yield RISE::TIClient::Status.failure(@errors.join("; "))
      else
        json = JSON.parse(response.body.to_s)
        yield RISE::TIClient::Status.success("#{response.status}: Success", json)
      end
    end
  end
end
