# frozen_string_literal: true

class RebootButtonComponent < ViewComponent::Base
  def initialize(item:)
    @item = item
  end

  def render?
    @item.rebootable?
  end

private
  attr_reader :item
end
