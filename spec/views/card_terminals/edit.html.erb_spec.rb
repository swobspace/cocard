require 'rails_helper'

RSpec.describe "card_terminals/edit", type: :view do
  let(:connector) { FactoryBot.create(:connector) }
  let(:card_terminal) {
    CardTerminal.create!(
      connector_id: connector.id,
      displayname: "MyString",
      mac: '01:23:45:67:89:ab',
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
      assert_select "input[name=?]", "card_terminal[mac]" do |input|
        assert input.attr("disabled").present?
      end
      assert_select "input[name=?]", "card_terminal[ip]"
      assert_select "input[name=?]", "card_terminal[slots]"
      assert_select "input[name=?]", "card_terminal[delivery_date]"
      assert_select "input[name=?]", "card_terminal[supplier]"
      assert_select "input[name=?]", "card_terminal[serial]"
      assert_select "input[name=?]", "card_terminal[id_product]"
    end
  end
end
