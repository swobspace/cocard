# frozen_string_literal: true

class Card::ContextAuthenticationComponent < ViewComponent::Base
  def initialize(card:, context:)
    @card = card
    @context = context
    @connector = card&.card_terminal&.connector
  end

  def message
    if connector.nil?
      text = "Karte keinem Konnektor zugeordnet"
      raw(%Q[<span class="badge bg-info">#{text}</span>])
    elsif connector.can_authenticate?(context.client_system)
      # text = "Authentifizierung ok"
      # raw(%Q[<span class="badge bg-success">#{text}</span>])
      ""
    else
      text = "Authentifizierung nicht möglich"
      title = "Bitte Authentifizierung beim Konnektor prüfen, Zertifikat oder User/Passwort fehlt"
      raw(%Q[<span class="badge bg-danger" title="#{title}">#{text}</span>])
    end
  end

private
  attr_reader :card, :context, :connector

end
