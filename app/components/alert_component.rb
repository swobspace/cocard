# frozen_string_literal: true

class AlertComponent < ViewComponent::Base
  def initialize(severity:, message:)
    @level = update_severity(severity)
    @message = message
  end

private

  # bootstrapify names
  def update_severity(severity)
    case severity.to_sym
    when :alert, :error
      "danger"
    when :notice
      "info"
    else
      severity.to_s
    end
  end

end
