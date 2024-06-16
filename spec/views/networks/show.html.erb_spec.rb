require 'rails_helper'

RSpec.describe "networks/show", type: :view do
  let(:location) { FactoryBot.create(:location, lid: 'AXC') }

  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'networks' }
    allow(controller).to receive(:action_name) { 'show' }

    assign(:network, 
      FactoryBot.create(:network, netzwerk: '198.51.100.128/29', 
                        location: location, description: "some more information"),
    )
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/198.51.100.128\/29/)
    expect(rendered).to match(/AXC/)
    expect(rendered).to match(/some more information/)
  end
end
