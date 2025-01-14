# frozen_string_literal: true

class MuteButtonComponent < ViewComponent::Base
  def initialize(mutable:, readonly: true, small: true)
    @mutable = mutable
    @readonly = readonly
    @small = small
  end

  def btn_size
    if small
      "btn-sm"
    else
      "btn"
    end
  end

  def button_css
    if mutable.muted
      "btn #{btn_size} btn-outline-secondary"
    else
      "btn #{btn_size} btn-warning"
    end
  end

  def button_action
    polymorphic_path(mutable)
  end

  def icon
    if mutable.muted
      '<i class="fa-regular fa-fw fa-bell"></i>'
    else
      '<i class="fa-regular fa-fw fa-bell-slash"></i>'
    end
  end

  private
  attr_reader :mutable, :readonly, :small

end
