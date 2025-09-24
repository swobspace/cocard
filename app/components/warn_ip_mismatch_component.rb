# frozen_string_literal: true

class WarnIpMismatchComponent < ViewComponent::Base
  def initialize(item:)
    @item = item
  end

  def render?
    item.ip != item.real_ip
  end

private
  attr_reader :item
end
