# frozen_string_literal: true

class TI::LagebildAlertButtonComponent < ViewComponent::Base
  def initialize
    @failed_count = SinglePicture.failed.count
    @critical = SinglePicture
                .with_failed_tids
                .select(:tid, 'sum(availability)')
                .group(:tid)
                .having("sum(availability) < 1")
                .any?
  end


  def color
    if @critical 
      "danger"
    else
      "warning text-white"
    end
  end
end
