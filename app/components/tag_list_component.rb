# frozen_string_literal: true

class TagListComponent < ViewComponent::Base
  def initialize(item:)
    @item = item
  end

  def render?
    item.respond_to?(:tag_list)
  end

private
  attr_reader :item
end
