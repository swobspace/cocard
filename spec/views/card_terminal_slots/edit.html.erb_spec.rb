require 'rails_helper'

RSpec.describe "card_terminal_slots/edit", type: :view do
  let(:card_terminal_slot) {
    CardTerminalSlot.create!(
      card_terminal: "MyString",
      slotid: "MyString",
      card: "MyString"
    )
  }

  before(:each) do
    assign(:card_terminal_slot, card_terminal_slot)
  end

  it "renders the edit card_terminal_slot form" do
    render

    assert_select "form[action=?][method=?]", card_terminal_slot_path(card_terminal_slot), "post" do

      assert_select "input[name=?]", "card_terminal_slot[card_terminal]"

      assert_select "input[name=?]", "card_terminal_slot[slotid]"

      assert_select "input[name=?]", "card_terminal_slot[card]"
    end
  end
end
