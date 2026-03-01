require 'rails_helper'

RSpec.describe "card_terminal_slots/show", type: :view do
  let(:ct) { FactoryBot.create(:card_terminal, :with_mac, name: "MyCardTerminal") }
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'card_terminal_slots' }
    allow(controller).to receive(:action_name) { 'show' }

    assign(:card_terminal_slot, CardTerminalSlot.create!(
      card_terminal: ct,
      slotid: 23,
    ))
    assign(:card_terminal, ct)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/MyCardTerminal \(\) \/ 23/)
    expect(rendered).to match(/23/)
  end
end
