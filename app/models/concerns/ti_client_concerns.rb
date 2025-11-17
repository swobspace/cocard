module TIClientConcerns
  extend ActiveSupport::Concern

  included do
  end

  def hintergrundaufgaben
    scheduler_state = "???"
    if client_secret.present?
      rtic = RISE::TIClient::System.new(ti_client: self)
      rtic.get_scheduler do |result|
        result.on_success do |msg, value|
          scheduler_state = value['state']
        end
        result.on_failure do |msg|
          scheduler_state = "Abfrage fehlgeschlagen"
        end
      end
    else
      scheduler_state = "Client-Secret fehlt, keine Abfrage möglich"
    end
    scheduler_state
  end

end
