require 'rails_helper'

RSpec.describe "workplaces/show", type: :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'workplaces' }
    allow(controller).to receive(:action_name) { 'show' }

    assign(:workplace, Workplace.create!(
      name: 'NB-AXC-0004',
      description: "some more information"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/NB-AXC-0004/)
    expect(rendered).to match(/some more information/)
  end
end
