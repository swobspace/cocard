# frozen_string_literal: true

require "rails_helper"

RSpec.describe TI::LagebildAlertButtonComponent, type: :component do
  include Rails.application.routes.url_helpers

  it "shows alert button" do
    sp = FactoryBot.create(:single_picture, availability: 0)
    render_inline(described_class.new())
    # puts rendered_content
    expect(page).to have_css('a[class="btn btn-danger mb-0"]')
    expect(page).to have_css(%Q[a[href="#{situation_picture_path(availability: 0)}"]])
  end

  it "don't show button" do
    sp = FactoryBot.create(:single_picture, availability: 1)
    render_inline(described_class.new())
    # puts rendered_content
    expect(page).not_to have_css('a[class="btn btn-danger mb-0"]')
    expect(page).not_to have_css(%Q[a[href="#{situation_picture_path(availability: 0)}"]])
  end


end
