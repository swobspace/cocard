# frozen_string_literal: true

class InvalidateButtonComponent < ViewComponent::Base
  def initialize(item:, readonly: true, small: true, grace_period: 2*Cocard::grace_period)
    @item = item
    @readonly = readonly
    @small = small
    @grace_period = grace_period
  end

  def btn_size
    if small
      "btn-sm"
    else
      "btn"
    end
  end

  def button_css
    "btn #{btn_size} btn-warning"
  end

  def button_action
    polymorphic_path(item)
  end

  def render?
    !readonly && error_state && is_outdated
  end

  private
  attr_reader :item, :type, :readonly, :small, :grace_period

  def error_state
    if item.kind_of? Log
      item.is_valid
    else
      item.condition >= Cocard::States::WARNING
    end
  end

  def is_outdated
    !last_seen.nil? && last_seen < (Time.current - grace_period)
  end

  def last_seen
    if item.respond_to?(:last_seen)
      item.last_seen
    else
      item.updated_at
    end
  end

end
