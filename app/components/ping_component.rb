# frozen_string_literal: true

class PingComponent < ViewComponent::Base
  def initialize(pingable:)
    @pingable = pingable
    @up   = @pingable.up?
  end

  private
  attr_reader :pingable, :up, :level, :message

  def level
    if up
      "info"
    else
      "danger"
    end
  end

  def message
    if up
      "#{pingable.class.name} is reachable."
    else
      "#{pingable.class.name} is unreachable!"
    end
  end
end
