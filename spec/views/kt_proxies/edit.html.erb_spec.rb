require 'rails_helper'

RSpec.describe "kt_proxies/edit", type: :view do
  let(:kt_proxy) { FactoryBot.create(:kt_proxy) }

  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    @ability.can :manage, KTProxy
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'kt_proxies' }
    allow(controller).to receive(:action_name) { 'edit' }

    assign(:kt_proxy, kt_proxy)
  end

  it "renders the edit kt_proxy form" do
    render

    assert_select "form[action=?][method=?]", kt_proxy_path(kt_proxy), "post" do
      assert_select "select[name=?]", "kt_proxy[card_terminal_id]"
      assert_select "input[name=?]", "kt_proxy[uuid]"
      assert_select "input[name=?]", "kt_proxy[name]"
      assert_select "input[name=?]", "kt_proxy[wireguard_ip]"
      assert_select "input[name=?]", "kt_proxy[incoming_port]"
      assert_select "input[name=?]", "kt_proxy[outgoing_ip]"
      assert_select "input[name=?]", "kt_proxy[outgoing_port]"
      assert_select "input[name=?]", "kt_proxy[card_terminal_ip]"
      assert_select "input[name=?]", "kt_proxy[card_terminal_port]"
    end
  end
end
