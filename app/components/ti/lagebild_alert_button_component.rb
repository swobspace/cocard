# frozen_string_literal: true

class TI::LagebildAlertButtonComponent < ViewComponent::Base
  def initialize
    @failed_count = SinglePicture.failed.count
    failure_group_ids = SinglePicture
                        .active.current.failed
                        .select(:pdt, :tid)
                        .group(:pdt, :tid)
                        .map{|x| SinglePicture.where(pdt: x.pdt, tid: x.tid).ids}
                        .flatten

    @critical = SinglePicture
                .where(id: failure_group_ids).active.current
                .select(:pdt, :tid, :availability)
                .group(:pdt, :tid)
                .sum("availability")
                .select {|x,y| y == 0}
                .any?
                # .with_failed_tids
                # .select(:tid, 'sum(availability)')
                # .group(:tid)
                # .having("sum(availability) < 1")
                # .any?
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
