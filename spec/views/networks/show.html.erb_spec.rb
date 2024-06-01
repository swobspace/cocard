require 'rails_helper'

RSpec.describe "networks/show", type: :view do
  before(:each) do
    assign(:network, Network.create!(
      netzwerk: "",
      description: nil,
      location: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
