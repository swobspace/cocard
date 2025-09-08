require 'rails_helper'

RSpec.describe "ti_clients/new", type: :view do
  before(:each) do
    assign(:ti_client, TIClient.new(
      connector: nil,
      name: "MyString",
      url: "MyString"
    ))
  end

  it "renders new ti_client form" do
    render

    assert_select "form[action=?][method=?]", ti_clients_path, "post" do

      assert_select "input[name=?]", "ti_client[connector_id]"

      assert_select "input[name=?]", "ti_client[name]"

      assert_select "input[name=?]", "ti_client[url]"
    end
  end
end
