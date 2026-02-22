require 'rails_helper'

RSpec.describe "card_terminal_slots/index", type: :view do
  before(:each) do
    assign(:card_terminal_slots, [
      CardTerminalSlot.create!(
        card_terminal: "Card Terminal",
        slotid: "Slotid",
        card: "Card"
      ),
      CardTerminalSlot.create!(
        card_terminal: "Card Terminal",
        slotid: "Slotid",
        card: "Card"
      )
    ])
  end

  it "renders a list of card_terminal_slots" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Card Terminal".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Slotid".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Card".to_s), count: 2
  end
end
