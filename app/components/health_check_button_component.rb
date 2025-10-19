# frozen_string_literal: true

class HealthCheckButtonComponent < ViewComponent::Base
  def initialize(item:, variant: :normal)
    @item = item
    @variant = variant
  end

  def render?
    @item.present? and @item.ip.present? and valid_ip?(@item.ip)
  end

  def btn_class
    case variant
    when :small
      'btn btn-sm btn-secondary'
    when :outline
      'btn btn-outline-secondary me-1'
    else
      'btn btn-secondary me-1'
    end
  end

  private
    attr_reader :item, :variant

    def valid_ip?(ip)
      !no_ip?(ip) && ip.present?
    end

    def no_ip?(ip)
      !!(ip.to_s =~ /\A127\.0\.0\./) || (ip.to_s == '0.0.0.0')
    end
end
