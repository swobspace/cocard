require 'rails_helper'

RSpec.describe "card_terminals/show", type: :view do
  let(:location)  { FactoryBot.create(:location, lid: 'AXC') }
  let(:connector) { FactoryBot.create(:connector) }

  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'card_terminals' }
    allow(controller).to receive(:action_name) { 'show' }

    assign(:card_terminal, CardTerminal.create!(
      connector_id: connector.id,
      displayname: "Displayname",
      description: "some other text",
      location_id: location.id
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Displayname/)
    expect(rendered).to match(/AXC/)
    expect(rendered).to match(/some other text/)
  end
end
