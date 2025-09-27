require 'rails_helper'

RSpec.describe "kt_proxies/show", type: :view do
  let(:tic) { FactoryBot.create(:ti_client, name: 'TIClient_XYZ') }
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    @ability.can :manage, KTProxy
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'kt_proxies' }
    allow(controller).to receive(:action_name) { 'show' }

    assign(:kt_proxy, KTProxy.create!(
      ti_client: tic,
      card_terminal: nil,
      uuid: "Uuid",
      name: "Name",
      wireguard_ip: "198.51.100.99",
      incoming_ip: "192.0.2.1",
      incoming_port: 8989,
      outgoing_ip: "192.0.2.2",
      outgoing_port: 8990,
      card_terminal_ip: "192.0.2.91",
      card_terminal_port: 4742
    ))
  end

  it "renders attributes in <p>" do
    render
    # expect(rendered).to match(//)
    expect(rendered).to match(/TIClient_XYZ/)
    expect(rendered).to match(/Uuid/)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/198.51.100.99/)
    expect(rendered).to match(/192.0.2.1/)
    expect(rendered).to match(/8989/)
    expect(rendered).to match(/8990/)
    expect(rendered).to match(/192.0.2.2/)
    expect(rendered).to match(/192.0.2.91/)
    expect(rendered).to match(/4742/)
  end
end
