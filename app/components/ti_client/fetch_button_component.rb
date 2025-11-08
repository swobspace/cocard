# frozen_string_literal: true

class TIClient::FetchButtonComponent < ViewComponent::Base
  def initialize(ti_client:)
    @ti_client = ti_client
  end

  def render?
    ti_client.client_secret.present?
  end

private
  attr_reader :ti_client
end
