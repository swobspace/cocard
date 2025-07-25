require 'rails_helper'

RSpec.describe "connectors/show", type: :view do
  let(:current) { Time.current }
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    @ability.can :read, Connector, :id_contract
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'connectors' }
    allow(controller).to receive(:action_name) { 'show' }
    @current_user = FactoryBot.create(:user, sn: 'Mustermann', givenname: 'Max')

    assign(:connector, Connector.create!(
      name: "Name",
      short_name: "K123",
      ip: "127.0.2.1",
      admin_url: "Admin Url",
      sds_url: "Sds Url",
      manual_update: false,
      description: "some text",
      last_check: current,
      last_ok: current,
      firmware_version: "123.456",
      id_contract: '919XaWZ3',
      serial: 'S12344321',
      use_tls: false,
      authentication: :basicauth,
      boot_mode: :cron,
      iccsn: "8027600355000099999",
      expiration_date: "2025-12-31",
      auth_user: 'myUser'
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/K123/)
    expect(rendered).to match(/127.0.2.1/)
    expect(rendered).to match(/Admin Url/)
    expect(rendered).to match(/Sds Url/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/some text/)
    expect(rendered).to match(/#{current.localtime.to_s.gsub('+', '.')}/)
    expect(rendered).to match(/123.456/)
    expect(rendered).to match(/919XaWZ3/)
    expect(rendered).to match(/S12344321/)
    expect(rendered).to match(/User\/Passwort/)
    expect(rendered).to match(/[ myUser ]/)
    expect(rendered).to match(/Nein/)
    expect(rendered).to match(/via Cron/)
    expect(rendered).to match(/8027600355000099999/)
    expect(rendered).to match(/2025-12-31/)
  end
end
