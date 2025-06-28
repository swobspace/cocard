# frozen_string_literal: true

class CheckValueComponent < ViewComponent::Base
  def initialize(value:, condition:, message:, icon: true, level: :info)
    @value = value
    @condition = condition
    @message = message
    @icon = icon
    @level = level
  end

  def set_icon
    return "" unless icon
    if condition
      Cocard::States.flag(Cocard::States::WARNING)
    else
      Cocard::States.flag(Cocard::States::OK)
    end
  end

  def bgclass
    if condition
      if level == :critical
        "badge text-bg-danger opacity-75"
      elsif level == :warning
        "badge text-bg-warning opacity-75"
      elsif level == :info
        "badge text-bg-info opacity-75"
      else
        ""
      end
    end
  end

private
  attr_reader :value, :condition, :message, :icon, :level

end
