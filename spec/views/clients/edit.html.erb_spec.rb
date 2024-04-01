require 'rails_helper'

RSpec.describe "clients/edit", type: :view do
  let(:client) {
    Client.create!(
      name: "MyString",
      description: "MyString"
    )
  }

  before(:each) do
    assign(:client, client)
  end

  it "renders the edit client form" do
    render

    assert_select "form[action=?][method=?]", client_path(client), "post" do

      assert_select "input[name=?]", "client[name]"

      assert_select "input[name=?]", "client[description]"
    end
  end
end
