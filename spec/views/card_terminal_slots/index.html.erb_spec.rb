require 'rails_helper'

RSpec.describe "card_terminal_slots/index", type: :view do
  let(:ct) { FactoryBot.create(:card_terminal, :with_mac, name: "MyCardTerminal") }
  let!(:card) { FactoryBot.create(:card, card_type: 'SMC-KT', iccsn: 12345678) }
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'card_terminal_slots' }
    allow(controller).to receive(:action_name) { 'edit' }

    cts1 = FactoryBot.create(:card_terminal_slot, card_terminal: ct, slotid: 17)
    cts2 = FactoryBot.create(:card_terminal_slot, card_terminal: ct, slotid: 18)

    assign(:card_terminal_slots, [cts1, cts2])
    card.update(card_terminal_slot_id: cts2.id)
    cts2.reload
  end

  it "renders a list of card_terminal_slots" do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new(/MyCardTerminal \(\)/), count: 2
    assert_select cell_selector, text: Regexp.new("17".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("18".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("12345678".to_s), count: 1
  end
end
