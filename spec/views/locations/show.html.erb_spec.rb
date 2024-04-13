require 'rails_helper'

RSpec.describe "locations/show", type: :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'locations' }
    allow(controller).to receive(:action_name) { 'show' }

    assign(:location, Location.create!(
      lid: "Lid",
      description: "Description"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Lid/)
    expect(rendered).to match(/Description/)
  end
end
