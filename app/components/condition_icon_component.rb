# frozen_string_literal: true

#
# Display condition as icon with some text as title
# item must respond_to :condition, :condition_text
#
class ConditionIconComponent < ViewComponent::Base
  def initialize(item:, small: false, period: Cocard::grace_period)
    @item = item
    @button_class = ""
    @icon  = ""
    @small = small
    @period = period
    set_variant
  end

  def set_variant
    if @small
      size = "btn btn-sm"
    else
      size = "btn"
    end

    case item.condition
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
        @icon  = "fa-solid fa-circle-xmark"
    end
  end

private
  attr_reader :item, :button_class, :icon, :period

  def outdated?
    item.updated_at < period.before(Time.current)
  end

  def btn
    ( outdated? ) ? "btn-outline" : "btn"
  end

  def textcolor
    ( outdated? ) ? "" : "text-white"
  end

end
