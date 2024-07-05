require 'rails_helper'

RSpec.describe "connectors/show", type: :view do
  let(:current) { Time.current }
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'connectors' }
    allow(controller).to receive(:action_name) { 'show' }
    @current_user = FactoryBot.create(:user, sn: 'Mustermann', givenname: 'Max')
    allow(@current_user).to receive(:is_admin?).and_return(true)

    assign(:connector, Connector.create!(
      name: "Name",
      ip: "127.0.2.1",
      admin_url: "Admin Url",
      sds_url: "Sds Url",
      manual_update: false,
      description: "some text",
      last_check: current,
      last_check_ok: current,
      firmware_version: "123.456",
      id_contract: '919XaWZ3',
      serial: 'S12344321',
      use_tls: false,
      authentication: :noauth
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/127.0.2.1/)
    expect(rendered).to match(/Admin Url/)
    expect(rendered).to match(/Sds Url/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/some text/)
    expect(rendered).to match(/#{current.localtime.to_s.gsub('+', '.')}/)
    expect(rendered).to match(/123.456/)
    expect(rendered).to match(/919XaWZ3/)
    expect(rendered).to match(/S12344321/)
    expect(rendered).to match(/Keine/)
    expect(rendered).to match(/Nein/)
  end
end
