require 'rails_helper'

RSpec.describe "ti_clients/new", type: :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    @ability.can :manage, KTProxy
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'ti_clients' }
    allow(controller).to receive(:action_name) { 'edit' }

    assign(:ti_client, FactoryBot.build(:ti_client))
  end

  it "renders new ti_client form" do
    render

    assert_select "form[action=?][method=?]", ti_clients_path, "post" do

      assert_select "select[name=?]", "ti_client[connector_id]"
      assert_select "input[name=?]", "ti_client[name]"
      assert_select "input[name=?]", "ti_client[url]"
      assert_select "input[name=?]", "ti_client[client_secret]"
    end
  end
end
