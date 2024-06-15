# frozen_string_literal: true

#
# Display condition as icon with some text as title
# item must respond_to :condition, :condition_text
#
class ConditionIconComponent < ViewComponent::Base
  def initialize(item:, small: false, period: Cocard::grace_period, as_text: false)
    @item  = item
    @color = ""
    @icon  = ""
    @text  = ""
    @as_text  = as_text
    @small = small
    @period = period
    set_variant
  end

  def set_variant
    if @small
      @size = "btn btn-sm"
    else
      @size = "btn"
    end

    case item.condition
      when Cocard::States::CRITICAL
        @color = "danger"
        @icon = "fa-solid fa-circle-exclamation"
        @text = "CRITICAL"
      when Cocard::States::UNKNOWN
        @color = "info"
        @icon = "fa-solid fa-circle-question #{textcolor}"
        @text = "UNKNOWN"
      when Cocard::States::WARNING
        @color = "warning"
        @icon = "fa-solid fa-triangle-exclamation #{textcolor}"
        @text = "WARNING"
      when Cocard::States::OK
        @color = "success"
        @icon = "fa-solid fa-circle-check"
        @text = "OK"
      else
        @color = "secondary"
        @icon = "fa-solid fa-circle-xmark"
        @text = "NOTHING"
    end
  end

private
  attr_reader :item, :color, :icon, :period, :as_text, :text, :size

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
