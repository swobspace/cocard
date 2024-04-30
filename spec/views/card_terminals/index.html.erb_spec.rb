require 'rails_helper'

RSpec.describe "card_terminals/index", type: :view do
  before(:each) do
    assign(:card_terminals, [
      CardTerminal.create!(
        displayname: "Displayname",
        location: nil
      ),
      CardTerminal.create!(
        displayname: "Displayname",
        location: nil
      )
    ])
  end

  it "renders a list of card_terminals" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new("Displayname".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
