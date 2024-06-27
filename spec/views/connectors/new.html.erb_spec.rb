require 'rails_helper'

RSpec.describe "connectors/new", type: :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'connectors' }
    allow(controller).to receive(:action_name) { 'new' }

    assign(:connector, Connector.new(
      name: "MyString",
      ip: "192.0.2.1",
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
      assert_select "input[name=?]", "connector[admin_url]"
      assert_select "input[name=?]", "connector[manual_update]"
      assert_select "input[name=?]", "connector[description]"
      assert_select "select[name=?]", "connector[location_ids][]"
      assert_select "input[name=?]", "connector[serial]"
      assert_select "input[name=?]", "connector[id_contract]"
      assert_select "input[name=?]", "connector[use_tls]"
      assert_select "select[name=?]", "connector[authentication]"
    end
  end
end
