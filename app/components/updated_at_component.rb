# frozen_string_literal: true

class UpdatedAtComponent < ViewComponent::Base
  def initialize(item:, period:)
    @item = item
    @period = period
  end

  def message
    updated_at = item.updated_at.localtime
    if item.updated_at.blank? or (item.updated_at < period.after(Time.current))
      Cocard::States.flag(Cocard::States::CRITICAL) + " #{updated_at}"
    else
      Cocard::States.flag(Cocard::States::OK) + " #{updated_at}"
    end
  end

private
  attr_reader :item, :period

end
