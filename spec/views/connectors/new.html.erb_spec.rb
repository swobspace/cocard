require 'rails_helper'

RSpec.describe "connectors/new", type: :view do
  before(:each) do
    assign(:connector, Connector.new(
      name: "MyString",
      ip: "",
      sds_url: "MyString",
      manual_update: false
    ))
  end

  it "renders new connector form" do
    render

    assert_select "form[action=?][method=?]", connectors_path, "post" do

      assert_select "input[name=?]", "connector[name]"

      assert_select "input[name=?]", "connector[ip]"

      assert_select "input[name=?]", "connector[sds_url]"

      assert_select "input[name=?]", "connector[manual_update]"
    end
  end
end
