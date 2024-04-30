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
        location_id: location.id
      ),
      CardTerminal.create!(
        connector_id: connector.id,
        displayname: "Displayname",
        description: "some other text",
        location_id: location.id
      )
    ])
  end

  it "renders a list of card_terminals" do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new("Displayname".to_s), count: 2
    assert_select cell_selector, text: Regexp.new('AXC'.to_s), count: 2
    # assert_select cell_selector, text: Regexp.new('some other text'.to_s), count: 2
  end
end
