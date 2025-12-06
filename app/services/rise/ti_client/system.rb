module RISE
  class TIClient::System < TIClient::Base
    def get_scheduler
      token = api_token
      if token.nil?
        @errors << "Authentifikation fehlgeschlagen"
      else
        @errors = []
        begin
          response = connection.get('/api/v1/manager/konnektor/default/task-scheduler',
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
        json = begin JSON.parse(response.body) rescue {} end
        yield RISE::TIClient::Status.success("#{response.status}: Success", json)
      end
    end
  end
end
