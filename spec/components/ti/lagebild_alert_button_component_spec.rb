# frozen_string_literal: true

require "rails_helper"

RSpec.describe TI::LagebildAlertButtonComponent, type: :component do
  include Rails.application.routes.url_helpers

  it "shows alert button" do
    sp = FactoryBot.create(:single_picture, time: Time.now, availability: 0)
    render_inline(described_class.new())
    # puts rendered_content
    expect(page).to have_css('a[class="btn btn-danger mb-0"]')
    expect(page).to have_css(%Q[a[href="#{failed_situation_picture_path()}"]])
  end

  it "shows warning button" do
    sp = FactoryBot.create(:single_picture, availability: 1, time: Time.now, tid: "tid-13")
    sp = FactoryBot.create(:single_picture, availability: 0, time: Time.now, tid: "tid-13")
    render_inline(described_class.new())
    # puts rendered_content
    expect(page).to have_css('a[class="btn btn-primary text-warning mb-0"]')
    expect(page).to have_css(%Q[a[href="#{failed_situation_picture_path()}"]])
  end

  it "don't show button" do
    sp = FactoryBot.create(:single_picture, availability: 1, time: Time.now, tid: "tid-13")
    render_inline(described_class.new())
    # puts rendered_content
    expect(page).to have_css('a[class="btn btn-primary text-success mb-0"]')
    expect(page).to have_css(%Q[a[href="#{failed_situation_picture_path()}"]])
  end

end
