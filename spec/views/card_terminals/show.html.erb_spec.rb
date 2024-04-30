require 'rails_helper'

RSpec.describe "card_terminals/show", type: :view do
  before(:each) do
    assign(:card_terminal, CardTerminal.create!(
      displayname: "Displayname",
      location: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Displayname/)
    expect(rendered).to match(//)
  end
end
