# frozen_string_literal: true

class LinkToComponent < ViewComponent::Base
  def initialize(item:, label_method: :to_s)
    @item = item
    @label_method = label_method
  end

  def render?
    item.present?
  end

private
  attr_reader :item, :label_method
  
end
