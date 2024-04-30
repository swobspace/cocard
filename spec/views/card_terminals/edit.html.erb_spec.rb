require 'rails_helper'

RSpec.describe "card_terminals/edit", type: :view do
  let(:card_terminal) {
    CardTerminal.create!(
      displayname: "MyString",
      location: nil
    )
  }

  before(:each) do
    assign(:card_terminal, card_terminal)
  end

  it "renders the edit card_terminal form" do
    render

    assert_select "form[action=?][method=?]", card_terminal_path(card_terminal), "post" do

      assert_select "input[name=?]", "card_terminal[displayname]"

      assert_select "input[name=?]", "card_terminal[location_id]"
    end
  end
end
