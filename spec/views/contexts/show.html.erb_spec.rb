require 'rails_helper'

RSpec.describe "contexts/show", type: :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'contexts' }
    allow(controller).to receive(:action_name) { 'show' }

    assign(:context, Context.create!(
      mandant: "Mandant",
      client_system: "Client System",
      workplace: "Workplace",
      description: "Description"
    ))

    @cards = []
    @connectors = []
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Mandant/)
    expect(rendered).to match(/Client System/)
    expect(rendered).to match(/Workplace/)
    expect(rendered).to match(/Description/)
  end
end
