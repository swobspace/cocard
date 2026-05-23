require 'rails_helper'

RSpec.describe "oids/edit", type: :view do
  let(:oid) {
    Oid.create!(
      oid: "MyString",
      name: "MyString",
      reference: "MyString"
    )
  }

  before(:each) do
    assign(:oid, oid)
  end

  it "renders the edit oid form" do
    render

    assert_select "form[action=?][method=?]", oid_path(oid), "post" do

      assert_select "input[name=?]", "oid[oid]"

      assert_select "input[name=?]", "oid[name]"

      assert_select "input[name=?]", "oid[reference]"
    end
  end
end
