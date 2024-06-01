require 'rails_helper'

RSpec.describe "networks/edit", type: :view do
  let(:network) {
    FactoryBot.create(:network, netzwerk: '198.51.100.96/29')
  }

  before(:each) do
    assign(:network, network)
  end

  it "renders the edit network form" do
    render

    assert_select "form[action=?][method=?]", network_path(network), "post" do

      assert_select "input[name=?]", "network[netzwerk]"

      assert_select "input[name=?]", "network[description]"

      assert_select "select[name=?]", "network[location_id]"
    end
  end
end
