require 'rails_helper'

RSpec.describe "kt_proxies/index", type: :view do
  let(:tic) { FactoryBot.create(:ti_client, name: 'TIClient_XYZ') }
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    @ability.can :manage, KTProxy
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'kt_proxies' }
    allow(controller).to receive(:action_name) { 'index' }

    assign(:kt_proxies, [
      KTProxy.create!(
        ti_client: tic,
        card_terminal: nil,
        uuid: "Uuid1",
        name: "Name",
        wireguard_ip: "198.51.100.99",
        incoming_ip: "192.0.2.1",
        incoming_port: 8989,
        outgoing_ip: "192.0.2.2",
        outgoing_port: 8990,
        card_terminal_ip: "192.0.2.91",
        card_terminal_port: 4742
      ),
      KTProxy.create!(
        ti_client: tic,
        card_terminal: nil,
        uuid: "Uuid2",
        name: "Name",
        wireguard_ip: "198.51.100.99",
        incoming_ip: "192.0.2.1",
        incoming_port: 8991,
        outgoing_ip: "192.0.2.2",
        outgoing_port: 8992,
        card_terminal_ip: "192.0.2.92",
        card_terminal_port: 4742
      )
    ])
  end

  it "renders a list of kt_proxies" do
    render
    cell_selector = 'tr>td'
    # assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("TIClient_XYZ".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Uuid".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("198.51.100.99".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("192.0.2.1".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(8989.to_s), count: 1
    assert_select cell_selector, text: Regexp.new(8990.to_s), count: 1
    assert_select cell_selector, text: Regexp.new(8991.to_s), count: 1
    assert_select cell_selector, text: Regexp.new(8992.to_s), count: 1
    assert_select cell_selector, text: Regexp.new("192.0.2.2".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("192.0.2.91".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("192.0.2.92".to_s), count: 1
    assert_select cell_selector, text: Regexp.new(4742.to_s), count: 2
  end
end
