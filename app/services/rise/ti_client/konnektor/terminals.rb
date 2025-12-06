module RISE
  class TIClient::Konnektor::Terminals < TIClient::Base
    def get_terminals
      token = api_token
      if token.nil?
        @errors << "Authentifikation fehlgeschlagen"
      else
        @errors = []
        begin
          apiurl  = ti_client&.url
          apiurl += "/api/v1/konnektor/default/api/v1/ctm/state"
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

      if response.present? && response.status == 403
        yield RISE::TIClient::Status.access_denied(@errors.join("; "))
      elsif @errors.any?
        yield RISE::TIClient::Status.failure(@errors.join("; "))
      else
        json = begin JSON.parse(response.body) rescue {} end
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
        json = begin JSON.parse(response.body) rescue {} end
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

    def begin_session(ct_id)
      token = api_token
      if token.nil?
        @errors << "Authentifikation fehlgeschlagen"
      else
        @errors = []
        begin
          apiurl  = ti_client&.url
          apiurl += '/api/v1/konnektor/default/api/v1/ctm/terminals/begin-session'
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

    def end_session(ct_id)
      token = api_token
      if token.nil?
        @errors << "Authentifikation fehlgeschlagen"
      else
        @errors = []
        begin
          apiurl  = ti_client&.url
          apiurl += '/api/v1/konnektor/default/api/v1/ctm/terminals/end-session'
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

    def add(kt_proxy)
      token = api_token
      if token.nil?
        @errors << "Authentifikation fehlgeschlagen"
      elsif !kt_proxy.kind_of?(KTProxy)
        @errors << "kein KT-Proxy angegeben"
      else
        @errors = []
        begin
          apiurl  = ti_client&.url
          apiurl += '/api/v1/konnektor/default/api/v1/ctm/terminals/add'
          response = HTTP.headers('Transfer-Encoding': 'chunked')
                         .auth("Bearer #{token}")
                         .post(apiurl,
                               ssl_context: ssl_verify_none,
                               json: { "ipAddress": kt_proxy.wireguard_ip.to_s,
                                      "tcpPort": kt_proxy.incoming_port }
                              )
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

    def change_correlation(ct_id, correlation)
      allowed_correlations = %w[ BEKANNT ZUGEWIESEN GEPAIRT AKTIV AKTUALISIEREND ]
      token = api_token
      if token.nil?
        @errors << "Authentifikation fehlgeschlagen"
      elsif !allowed_correlations.include?(correlation)
        @errors << "Wert #{correlation} für neuen Korrelationszustand nicht erlaubt"
      else
        @errors = []
        begin
          apiurl  = ti_client&.url
          apiurl += '/api/v1/konnektor/default/api/v1/ctm/terminals/change-correlation'
          response = HTTP.headers('Transfer-Encoding': 'chunked')
                         .auth("Bearer #{token}")
                         .post(apiurl,
                              ssl_context: ssl_verify_none,
                              json: {"ctId": "#{ct_id}", "correlation": correlation})
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
        json = begin JSON.parse(response.body) rescue {} end
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
        json = begin JSON.parse(response.body.to_s) rescue {} end
        yield RISE::TIClient::Status.success("#{response.status}: Success", json)
      end
    end
  end
end
