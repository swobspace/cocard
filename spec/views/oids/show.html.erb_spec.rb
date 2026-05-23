require 'rails_helper'

RSpec.describe "oids/show", type: :view do
  before(:each) do
    assign(:oid, Oid.create!(
      oid: "Oid",
      name: "Name",
      reference: "Reference"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Oid/)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Reference/)
  end
end
