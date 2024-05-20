# frozen_string_literal: true

class UpdatedAtComponent < ViewComponent::Base
  def initialize(item:, period: Cocard::grace_period)
    @item = item
    @period = period
  end

  def message
    updated_at = item.updated_at
    if updated_at.blank? or (updated_at < period.before(Time.current))
      Cocard::States.flag(Cocard::States::WARNING) + " #{updated_at.localtime}"
    else
      Cocard::States.flag(Cocard::States::OK) + " #{updated_at.localtime}"
    end
  end

private
  attr_reader :item, :period

end
