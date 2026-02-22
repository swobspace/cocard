require 'rails_helper'

RSpec.describe "card_terminal_slots/show", type: :view do
  before(:each) do
    assign(:card_terminal_slot, CardTerminalSlot.create!(
      card_terminal: "Card Terminal",
      slotid: "Slotid",
      card: "Card"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Card Terminal/)
    expect(rendered).to match(/Slotid/)
    expect(rendered).to match(/Card/)
  end
end
