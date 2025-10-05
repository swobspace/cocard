# frozen_string_literal: true

class ExpirationDateComponent < ViewComponent::Base
  def initialize(item:)
    @item = item
    do_prepare
  end

  def render?
    !!item
  end

  def do_prepare
    return if item.blank?
    if item.expiration_date.blank?
      @msg_class = ""
      @message = Cocard::States.flag(Cocard::States::NOTHING)
    elsif item.expiration_date >= 3.month.after(Date.current)
      @msg_class = ""
      @message = Cocard::States.flag(Cocard::States::OK) + " #{item.expiration_date}"
    elsif item.expiration_date >= Date.current
      @msg_class = "badge text-bg-warning ms-1"
      @message = Cocard::States.flag(Cocard::States::WARNING) + 
                 %Q[<span class="#{@msg_class}"> #{item.expiration_date} </span>]
    else
      @msg_class = "badge text-bg-danger ms-1"
      @message = Cocard::States.flag(Cocard::States::CRITICAL) + 
                 %Q[<span class="#{@msg_class}"> #{item.expiration_date} </span>]
    end
    @message = @message.html_safe
  end

private
  attr_reader :item, :msg_class, :message



end
