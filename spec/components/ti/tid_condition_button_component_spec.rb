# frozen_string_literal: true

require "rails_helper"

RSpec.describe TI::TidConditionButtonComponent, type: :component do
  it "shows alert button" do
    render_inline(described_class.new(count: 0))
    expect(page).to have_css('button[class="btn btn-danger"]')
  end

  it "shows warning button" do
    render_inline(described_class.new(count: 3))
    expect(page).to have_css('button[class="btn btn-warning text-white"]')
  end

end
