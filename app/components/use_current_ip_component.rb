# frozen_string_literal: true

class UseCurrentIpComponent < ViewComponent::Base
  def initialize(item:)
    @item = item
  end

  def render?
    (item.current_ip != item.ip)
  end

  def update_url
    polymorphic_path(item, card_terminal: {ip: item.current_ip})
  end

private
  attr_reader :item
end
