# frozen_string_literal: true

class CertExpirationButtonComponent < ViewComponent::Base
  def initialize(expiration_date:, warn_period: 90, variant: :normal)
    @expiration_date = expiration_date
    @variant = variant
    @warn_period = 90
    prepare_button
  end

  def render?
    expiration_date.present? and (expiration_date <= warn_period.days.after(Date.current))
  end


private
  attr_reader :expiration_date, :variant, :warn_period, :button_class, :title

  def prepare_button
    return if expiration_date.blank?
    if expiration_date <= Date.current
      @button_class = "btn #{small} btn-danger"
      @title = "Zertifikat ist abgelaufen!"
    else
      @button_class = "btn #{small} btn-warning"
      @title = "Zertifikat läuft in #{(expiration_date - Date.current).to_i} Tagen ab"
    end
  end

  def small
    case variant
    when :small
      "btn-sm"
    else
      ""
    end
  end
end
