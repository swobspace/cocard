require 'rails_helper'

RSpec.describe "operational_states/show", type: :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'operational_states' }
    allow(controller).to receive(:action_name) { 'show' }

    assign(:operational_state, OperationalState.create!(
      name: "Name",
      description: "Description",
      operational: true
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Description/)
    expect(rendered).to match(/true/)
  end
end
