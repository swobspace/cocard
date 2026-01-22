# frozen_string_literal: true

class FetchCardCertificatesButtonComponent < ViewComponent::Base
  def initialize(item:)
    @item = item
  end

  def button_action
    polymorphic_path([:fetch, item, :card_certificates])
  end

  def button_css
    "btn btn-warning me-1"
  end

  private
    attr_reader :item
end
