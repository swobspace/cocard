require 'rails_helper'

RSpec.describe "card_terminals/edit", type: :view do
  let(:connector) { FactoryBot.create(:connector) }
  let(:card_terminal) {
    CardTerminal.create!(
      connector_id: connector.id,
      displayname: "MyString",
      location: nil
    )
  }

  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'card_terminals' }
    allow(controller).to receive(:action_name) { 'edit' }
    assign(:card_terminal, card_terminal)
  end

  it "renders the edit card_terminal form" do
    render

    assert_select "form[action=?][method=?]", card_terminal_path(card_terminal), "post" do
      assert_select "input[name=?]", "card_terminal[displayname]"
      assert_select "select[name=?]", "card_terminal[location_id]"
      assert_select "input[name=?]", "card_terminal[description]"
      assert_select "input[name=?]", "card_terminal[room]"
      assert_select "input[name=?]", "card_terminal[contact]"
      assert_select "input[name=?]", "card_terminal[plugged_in]"
    end
  end
end
