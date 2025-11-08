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

      if @errors.any?
        yield RISE::TIClient::Status.failure(@errors.join("; "))
      else
        json = JSON.parse(response.body)
        yield RISE::TIClient::Status.success("#{response.status}: Success", json)
      end
    end
  end
end
