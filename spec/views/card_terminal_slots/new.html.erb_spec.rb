require 'rails_helper'

RSpec.describe "card_terminal_slots/new", type: :view do
  before(:each) do
    assign(:card_terminal_slot, CardTerminalSlot.new(
      card_terminal: "MyString",
      slotid: "MyString",
      card: "MyString"
    ))
  end

  it "renders new card_terminal_slot form" do
    render

    assert_select "form[action=?][method=?]", card_terminal_slots_path, "post" do

      assert_select "input[name=?]", "card_terminal_slot[card_terminal]"

      assert_select "input[name=?]", "card_terminal_slot[slotid]"

      assert_select "input[name=?]", "card_terminal_slot[card]"
    end
  end
end
