require 'rails_helper'

RSpec.describe "card_terminals/index", type: :view do
  let(:location)  { FactoryBot.create(:location, lid: 'AXC') }
  let(:connector) { FactoryBot.create(:connector) }

  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'card_terminals' }
    allow(controller).to receive(:action_name) { 'index' }

    assign(:card_terminals, [
      CardTerminal.create!(
        connector_id: connector.id,
        displayname: "Displayname",
        description: "some other text",
        location_id: location.id,
        name: "ORGA-DINGDONG001",
        ct_id: "CT_ID0815",
        mac: "00-0D-F8-07-2C-67",
        ip: "127.0.0.5",
        connected: true,
        condition: Cocard::States::UNKNOWN
      ),
      CardTerminal.create!(
        connector_id: connector.id,
        displayname: "Displayname",
        description: "some other text",
        location_id: location.id,
        name: "ORGA-DINGDONG006",
        ct_id: "CT_ID0816",
        mac: "00-0D-F8-07-2C-68",
        ip: "127.0.0.6",
        connected: true,
        condition: Cocard::States::UNKNOWN
      )
    ])
  end

  it "renders a list of card_terminals" do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new("Displayname".to_s), count: 2
    assert_select cell_selector, text: Regexp.new('AXC'.to_s), count: 2
    assert_select cell_selector, text: Regexp.new('ORGA-DINGDONG00.'.to_s), count: 2
    # assert_select cell_selector, text: Regexp.new('some other text'.to_s), count: 2
  end
end
