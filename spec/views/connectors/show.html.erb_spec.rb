require 'rails_helper'

RSpec.describe "connectors/show", type: :view do
  before(:each) do
    assign(:connector, Connector.create!(
      name: "Name",
      ip: "",
      sds_url: "Sds Url",
      manual_update: false
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(//)
    expect(rendered).to match(/Sds Url/)
    expect(rendered).to match(/false/)
  end
end
