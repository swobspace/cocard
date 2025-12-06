# frozen_string_literal: true

class IsCurrentComponent < ViewComponent::Base
  def initialize(item:, attr:, grace_period: Cocard::grace_period, relative: false, icon: true)
    @item = item
    @attr = attr
    @grace_period = grace_period
    @relative = relative
    @icon = icon
  end

  def render?
    item.present?
  end

  def message
    if !icon
      show_time.to_s
    elsif to_check.blank? 
      Cocard::States.flag(Cocard::States::WARNING)
    elsif to_check < grace_period.before(Time.current)
      Cocard::States.flag(Cocard::States::WARNING) + " #{show_time}"
    else
      Cocard::States.flag(Cocard::States::OK) + " #{show_time}"
    end
  end


private
  attr_reader :item, :grace_period, :attr, :relative, :icon

  def to_check
    @to_check ||= item.send(attr) || ""
  end

  def show_time
    return "" if to_check.blank?
    if relative
      time_distance(to_check)
    else
      to_check.localtime
    end
  end

  def time_distance(ts)
    return "" if ts.blank?
    tdist = Time.current - ts
    case
      when tdist >= 1.year
        "#{(tdist/(12*30*24*3600)).round} year(s)"
      when tdist >= 1.month
        "#{(tdist/(30*24*3600)).round} month(s)"
      when tdist >= 1.day
        "#{(tdist/(24*3600)).round} day(s)"
      when tdist >= 1.hour
        "#{(tdist/3600).round} h"
      when tdist >= 1.minute
        "#{(tdist/60).round} min"
      else
        "aktuell"
    end
  end

end
