# frozen_string_literal: true

class TIClient::RemotePinPlusStateComponent < ViewComponent::Base
  def initialize(card:)
    @card = card
    unless card.respond_to?(:state) and card.respond_to?(:iccsn)
      raise RuntimeError, "Card does not support :state or :iccsn"
    end
  end

  def badge_class
    case card.state
    when "ACTIVE"
      "badge text-bg-success"
    when "PENDING"
      "badge text-bg-info"
    when "ERROR"
      "badge text-bg-alert"
    when "MISSING"
      "badge text-bg-WARNING"
    when "CONFIGURABLE"
      "badge text-bg-light"
    when "CT_NOT_SUPPORTED"
      "badge text-bg-secondary"
    end
  end

private
  attr_reader :card
end
