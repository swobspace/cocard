require 'rails_helper'

RSpec.describe "card_terminals/new", type: :view do
  before(:each) do
    assign(:card_terminal, CardTerminal.new(
      displayname: "MyString",
      location: nil
    ))
  end

  it "renders new card_terminal form" do
    render

    assert_select "form[action=?][method=?]", card_terminals_path, "post" do

      assert_select "input[name=?]", "card_terminal[displayname]"

      assert_select "input[name=?]", "card_terminal[location_id]"
    end
  end
end
