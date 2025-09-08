require 'rails_helper'

RSpec.describe "ti_clients/show", type: :view do
  before(:each) do
    assign(:ti_client, TIClient.create!(
      connector: nil,
      name: "Name",
      url: "Url"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Url/)
  end
end
