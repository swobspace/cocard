# frozen_string_literal: true

class ErrorLevelBadgeComponent < ViewComponent::Base
  def initialize(level:)
    @level = level
  end

  def color
    case level.downcase
    when "fatal"
      "bg-alert"
    when "error", "critical"
        "text-bg-danger"
    when "warn", "warning"
        "text-bg-warning"
    when "info", "ok"
        "text-bg-light"
    when "unknown"
        "text-bg-info"
    else
      "text-bg-secondary"
    end
  end

private
  attr_reader :level

end
