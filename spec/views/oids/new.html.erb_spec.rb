require 'rails_helper'

RSpec.describe "oids/new", type: :view do
  before(:each) do
    assign(:oid, Oid.new(
      oid: "MyString",
      name: "MyString",
      reference: "MyString"
    ))
  end

  it "renders new oid form" do
    render

    assert_select "form[action=?][method=?]", oids_path, "post" do

      assert_select "input[name=?]", "oid[oid]"

      assert_select "input[name=?]", "oid[name]"

      assert_select "input[name=?]", "oid[reference]"
    end
  end
end
