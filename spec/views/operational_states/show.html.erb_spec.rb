require 'rails_helper'

RSpec.describe "operational_states/show", type: :view do
  before(:each) do
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
