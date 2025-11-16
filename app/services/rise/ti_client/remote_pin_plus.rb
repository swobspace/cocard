module RISE
  class TIClient::RemotePinPlus < TIClient::Base
    def get_configurations
      token = api_token
      if token.nil?
        @errors << "Authentifikation fehlgeschlagen"
      else
        @errors = []
        begin
          apiurl  = ti_client&.url
          apiurl += '/api/v1/premium/pin-plus'
          response = HTTP.auth("Bearer #{token}")
                         .get(apiurl, ssl_context: ssl_verify_none)
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
  end
end
