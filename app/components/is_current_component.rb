# frozen_string_literal: true

class IsCurrentComponent < ViewComponent::Base
  def initialize(item:, attr:, grace_period: Cocard::grace_period)
    @item = item
    @attr = attr
    @grace_period = grace_period
  end

  def message
    to_check = item.send(attr) || ""
    if to_check.blank? 
      Cocard::States.flag(Cocard::States::WARNING)
    elsif to_check < grace_period.before(Time.current)
      Cocard::States.flag(Cocard::States::WARNING) + " #{to_check.localtime}"
    else
      Cocard::States.flag(Cocard::States::OK) + " #{to_check.localtime}"
    end
  end


private
  attr_reader :item, :grace_period, :attr

end
