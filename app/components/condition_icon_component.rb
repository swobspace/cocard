# frozen_string_literal: true

#
# Display condition as icon with some text as title
# item must respond_to :condition, :condition_text
#
class ConditionIconComponent < ViewComponent::Base
  def initialize(item:, small: false, period: Cocard::grace_period, as_text: false)
    @item  = item
    @color = ""
    @icon  = ""
    @text  = ""
    @as_text  = as_text
    @small = small
    @period = period
    if item.present?
      set_variant
    end
  end

  def render?
    item.present?
  end

  def set_variant
    if @small
      @size = "btn btn-sm"
    else
      @size = "btn"
    end

    if deleted
      @color = "secondary"
      @icon = "fa-solid fa-fw fa-trash"
      @text = "NOTHING"
    else
      case item.condition
      when Cocard::States::CRITICAL
        @color = "danger"
        @icon = "fa-solid fa-fw fa-circle-exclamation"
        @text = "CRITICAL"
      when Cocard::States::UNKNOWN
        @color = "info"
        @icon = "fa-solid fa-fw fa-circle-question #{textcolor}"
        @text = "UNKNOWN"
      when Cocard::States::WARNING
        @color = "warning"
        @icon = "fa-solid fa-fw fa-triangle-exclamation #{textcolor}"
        @text = "WARNING"
      when Cocard::States::OK
        @color = "success"
        @icon = "fa-solid fa-fw fa-circle-check"
        @text = "OK"
      else
        @color = "secondary"
        @icon = "fa-solid fa-fw fa-circle-xmark"
        @text = "NOTHING"
      end
    end
  end

  def cert_badge
    return unless item.kind_of? Connector
    return unless item.respond_to?(:expiration_date)
    return unless item.expiration_date.present?
    return if item.expiration_date > 90.days.after(Date.current)
    if item.expiration_date <= Date.current
      color = "danger"
      title = "Das Zertifikat ist abgelaufen!"
    else 
      color = "warning"
      title = "Das Zertifikat läuft in #{(item.expiration_date - Date.current).to_i} Tagen ab!"

    end
    badge =<<~EOFBADGE
      <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-#{color}"
            title="#{title}"
      > 
        <i class="fa-solid fa-fw fa-sim-card"></i>
      </span>
EOFBADGE
    badge = badge.html_safe
  end

private
  attr_reader :item, :color, :icon, :period, :as_text, :text, :size

  def outdated?
    unless item.updated_at.nil?
      !deleted && (item.updated_at < period.before(Time.current))
    end
  end

  def btn
    ( outdated? ) ? "btn-outline" : "btn"
  end

  def textcolor
    ( outdated? ) ? "" : "text-white"
  end

  def deleted
    item.respond_to?(:deleted?) and item.deleted?
  end
end
