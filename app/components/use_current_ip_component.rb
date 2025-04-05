# frozen_string_literal: true

class UseCurrentIpComponent < ViewComponent::Base
  def initialize(item:)
    @item = item
  end

  def render?
    (item.current_ip != item.ip) && real_ip?(item.current_ip)
  end

  def update_url
    polymorphic_path(item, card_terminal: {ip: item.current_ip})
  end

private
  attr_reader :item

  def real_ip?(ip)
    !ip.nil? && (ip.to_s !~ /\A127\.0\.0\./) && (ip.to_s != '0.0.0.0')
  end
end
