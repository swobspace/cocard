require 'rails_helper'

RSpec.describe "contexts/show", type: :view do
  before(:each) do
    assign(:context, Context.create!(
      mandant: "Mandant",
      client_system: "Client System",
      workplace: "Workplace",
      description: "Description"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Mandant/)
    expect(rendered).to match(/Client System/)
    expect(rendered).to match(/Workplace/)
    expect(rendered).to match(/Description/)
  end
end
