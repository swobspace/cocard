# frozen_string_literal: true

class ConditionBadgeComponent < ViewComponent::Base
  def initialize(state:, count:, small: false)
    @state = state
    @count = count
    @button_class = ""
    @icon  = ""
    # @small = small
    set_variant
  end

  def set_variant
    if @small
      size = "btn btn-sm"
    else
      size = "btn"
    end

    if count == 0
      btn = "btn-outline"
      textcolor = ""
    else
      btn = "btn"
      textcolor = "text-white"
    end

    case state
     when Cocard::States::CRITICAL
        @button_class = "#{size} #{btn}-danger"
        @icon  = "fa-solid fa-circle-exclamation"
      when Cocard::States::UNKNOWN
        @button_class = "#{size} #{btn}-info"
        @icon  = "fa-solid fa-circle-question #{textcolor}"
      when Cocard::States::WARNING
        @button_class = "#{size} #{btn}-warning"
        @icon  = "fa-solid fa-triangle-exclamation #{textcolor}"
      when Cocard::States::OK
        @button_class = "#{size} #{btn}-success"
        @icon  = "fa-solid fa-circle-check"
      else
        @button_class = "#{size} #{btn}-secondary"
        @icon  = "fa-solid fa-circle-question"
    end
  end

private
  attr_reader :state, :button_class, :icon, :count
end
