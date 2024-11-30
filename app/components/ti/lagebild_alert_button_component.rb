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


  def cssclass
    if @critical
      "btn btn-danger mb-0"
    elsif @failed_count > 0
      "btn btn-primary text-warning mb-0"
    else
      "btn btn-primary text-success mb-0"
    end
  end
end
