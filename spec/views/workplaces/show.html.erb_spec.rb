require 'rails_helper'

RSpec.describe "workplaces/show", type: :view do
  before(:each) do
    assign(:workplace, Workplace.create!(
      description: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
  end
end
