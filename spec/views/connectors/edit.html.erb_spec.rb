require 'rails_helper'

RSpec.describe "connectors/edit", type: :view do
  let(:connector) {
    Connector.create!(
      name: "MyString",
      ip: "",
      sds_url: "MyString",
      manual_update: false
    )
  }

  before(:each) do
    assign(:connector, connector)
  end

  it "renders the edit connector form" do
    render

    assert_select "form[action=?][method=?]", connector_path(connector), "post" do

      assert_select "input[name=?]", "connector[name]"

      assert_select "input[name=?]", "connector[ip]"

      assert_select "input[name=?]", "connector[sds_url]"

      assert_select "input[name=?]", "connector[manual_update]"
    end
  end
end
