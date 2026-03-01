require 'rails_helper'

RSpec.describe "card_terminal_slots/edit", type: :view do
  let(:ct) { FactoryBot.create(:card_terminal, :with_mac) }
  let(:card_terminal_slot) {
    CardTerminalSlot.create!(
      card_terminal_id: ct.id,
      slotid: 23
    )
  }

  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'card_terminal_slots' }
    allow(controller).to receive(:action_name) { 'edit' }

    assign(:card_terminal_slot, card_terminal_slot)
    assign(:card_terminal, ct)
  end

  it "renders the edit card_terminal_slot form" do
    render

    assert_select "form[action=?][method=?]", card_terminal_card_terminal_slot_path(ct, card_terminal_slot), "post" do

      assert_select "select[name=?]", "card_terminal_slot[card_terminal_id]"

      assert_select "input[name=?]", "card_terminal_slot[slotid]"

      assert_select "select[name=?]", "card_id"
    end
  end
end
