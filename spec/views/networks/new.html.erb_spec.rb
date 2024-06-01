require 'rails_helper'

RSpec.describe "networks/new", type: :view do
  before(:each) do
    assign(:network, 
      FactoryBot.build(:network, netzwerk: '198.51.100.96/29')
    )
  end

  it "renders new network form" do
    render

    assert_select "form[action=?][method=?]", networks_path, "post" do

      assert_select "input[name=?]", "network[netzwerk]"

      assert_select "input[name=?]", "network[description]"

      assert_select "select[name=?]", "network[location_id]"
    end
  end
end
