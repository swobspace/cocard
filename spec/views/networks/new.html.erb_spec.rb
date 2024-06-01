require 'rails_helper'

RSpec.describe "networks/new", type: :view do
  before(:each) do
    assign(:network, Network.new(
      netzwerk: "",
      description: nil,
      location: nil
    ))
  end

  it "renders new network form" do
    render

    assert_select "form[action=?][method=?]", networks_path, "post" do

      assert_select "input[name=?]", "network[netzwerk]"

      assert_select "input[name=?]", "network[description]"

      assert_select "input[name=?]", "network[location_id]"
    end
  end
end
