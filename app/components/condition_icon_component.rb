# frozen_string_literal: true

#
# Display condition as icon with some text as title
# item must respond_to :condition, :condition_text
#
class ConditionIconComponent < ViewComponent::Base
  def initialize(item:)
    @item = item
    @color = ""
    @icon  = ""
    set_variant
  end

  def set_variant
    case item.condition
     when Cocard::States::CRITICAL
        @color = "btn-danger"
        @icon  = "fa-solid fa-circle-exclamation"
      when Cocard::States::UNKNOWN
        @color = "bg-UNKNOWN"
        @icon  = "fa-solid fa-circle-question text-white"
      when Cocard::States::WARNING
        @color = "btn-warning"
        @icon  = "fa-solid fa-triangle-exclamation text-white"
      when Cocard::States::OK
        @color = "btn-success"
        @icon  = "fa-solid fa-circle-check"
    end
  end

private
  attr_reader :item, :color, :icon
end
