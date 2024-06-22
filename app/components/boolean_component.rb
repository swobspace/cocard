# frozen_string_literal: true

class BooleanComponent < ViewComponent::Base
  def initialize(value:, text: :text)
    @value = value
    @text = text
  end

  def display
    if text == :text
      boolean_text
    elsif text == :unicode
      boolean_unicode
    else
      value
    end
  end

private
  attr_reader :value, :text

  def boolean_text
    I18n.t(value)
  end

  def boolean_unicode
    if value
      raw("<span>\u2705</span><span class='hidden'>" + I18n.t(value) + "</span>")
    else
      raw("<span>\u274C</span><span class='hidden'>" + I18n.t(value) + "</span>")
    end
  end

end
