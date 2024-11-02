# frozen_string_literal: true

class TI::LagebildAlertButtonComponent < ViewComponent::Base
  def initialize
    @failed_count = SinglePicture.failed.count
  end
end
