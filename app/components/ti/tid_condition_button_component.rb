# frozen_string_literal: true

class TI::TidConditionButtonComponent < ViewComponent::Base
  def initialize(count:)
    @count = count
  end

  def icon
    if count > 0
      "fa-solid fa-circle-exclamation"
    else
      "fa-solid fa-triangle-exclamation"
    end
  end

  def color
    if count > 0
      "warning text-white"
    else
      "danger"
    end
  end

  def size
    "btn"
  end

private
  attr_reader :count, :tid
end
