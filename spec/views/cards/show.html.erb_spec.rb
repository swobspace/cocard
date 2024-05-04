require 'rails_helper'

RSpec.describe "cards/show", type: :view do
  before(:each) do
    assign(:card, Card.create!(
      name: "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
