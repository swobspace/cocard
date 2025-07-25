require 'rails_helper'

RSpec.describe "connectors/index", type: :view do
  let(:location) { FactoryBot.create(:location, lid: 'AAC') }
  let(:current) { Time.current }

  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    @ability.can :read, Connector, :id_contract
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'connectors' }
    allow(controller).to receive(:action_name) { 'index' }
    @current_user = FactoryBot.create(:user, sn: 'Mustermann', givenname: 'Max')

    assign(:connectors, [
      Connector.create!(
        name: "Name",
        short_name: "K123",
        ip: "127.0.2.1",
        admin_url: "Admin Url",
        sds_url: "Sds Url",
        manual_update: false,
        location_ids: [location.id],
        last_check: current,
        last_ok: current,
        firmware_version: "123.456",
        id_contract: '919XaWZ3',
        serial: 'S12344321',
        authentication: :clientcert,
        boot_mode: :cron,
        use_tls: true,
        vpnti_online: true,
        soap_request_success: true,
        condition_message: "Quark",
        iccsn: "8027600355000099999",
        expiration_date: "2025-12-31"
      ),
      Connector.create!(
        name: "Name",
        short_name: "K124",
        ip: "127.0.2.2",
        admin_url: "Admin Url",
        sds_url: "Sds Url",
        manual_update: false,
        location_ids: [location.id],
        last_check: current,
        last_ok: current,
        firmware_version: "123.456",
        id_contract: '919XaWZ3',
        serial: 'S12344321',
        authentication: :noauth,
        boot_mode: :cron,
        use_tls: false,
        vpnti_online: false,
        condition_message: "Quark",
        iccsn: "8027600355000099999",
        expiration_date: "2025-12-31"
      )
    ])
  end

  it "renders a list of connectors" do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("K123".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("K124".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("127.0.2.1".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("127.0.2.2".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("Admin Url".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Sds Url".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(false.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("AAC".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("#{current.localtime.to_s.gsub('+', '.')}"), count: 4
    assert_select cell_selector, text: Regexp.new("123.456".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("919XaWZ3".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("S12344321".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("\u2705".to_s), count: 6
    assert_select cell_selector, text: Regexp.new("\u274C".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("Ja".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Nein".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Client-Zertifikat".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("Keine".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("UNKNOWN".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("via Cron".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("OK Konnektor online".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("UNKNOWN SOAP-Abfrage fehlgeschlagen, Konfigurationsproblem, Port nicht erreichbar oder Konnektor funktioniert nicht richtig".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("2025-12-31".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("8027600355000099999".to_s), count: 2
  end
end
