# frozen_string_literal: true

class FormComponent < ViewComponent::Base
  def initialize(title:, back: nil)
    @title = title
    @back = back
  end

end
