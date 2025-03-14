require 'rails_helper'

RSpec.describe "CardTerminals", type: :feature, js: true do
  let(:ts)        { Time.current }
  let(:location)  { FactoryBot.create(:location, lid: 'AXC') }
  let(:connector) { FactoryBot.create(:connector, name: 'TIK-XXX-39' ) }

  let!(:card_terminals) do  
    @card_terminals = [
      CardTerminal.create!(
        connector_id: connector.id,
        displayname: "Displayname",
        idle_message: "K123 MAC",
        description: "some other text",
        location_id: location.id,
        name: "ORGA-DINGDONG001",
        ct_id: "CT_ID_0815",
        mac: "00-0D-F8-07-2C-67",
        ip: "127.0.0.5",
        current_ip: "127.0.0.5",
        connected: true,
        room: "Raum U.16",
        contact: "Der Hausmeister",
        plugged_in: "Dose 17/4, Patchfeld 5",
        supplier: 'ACME Ltd',
        delivery_date: '2023-12-14',
        firmware_version: '3.1.9',
        serial: '11122277634',
        id_product: 'ORGA61411',
        pin_mode: 'on_demand',
        last_ok: ts,
      ),
      CardTerminal.create!(
        connector_id: connector.id,
        displayname: "Displayname",
        idle_message: "K123 MAC",
        description: "some other text",
        location_id: location.id,
        name: "ORGA-DINGDONG006",
        ct_id: "CT_ID_0817",
        mac: "00-0D-F8-07-2C-68",
        ip: "127.0.0.6",
        current_ip: "127.0.0.6",
        connected: true,
        room: "Raum U.16",
        contact: "Der Hausmeister",
        plugged_in: "Dose 17/4, Patchfeld 5",
        supplier: 'ACME Ltd',
        delivery_date: '2023-12-14',
        firmware_version: '3.1.9',
        serial: '11122277634',
        id_product: 'ORGA61411',
        pin_mode: 'on_demand',
        last_ok: ts,
      )
    ]
  end

  it "visit card_terminals_path" do
    @card_terminals.map{|ct| ct.reload}
    login_user(role: 'Admin')

    visit card_terminals_path
    expect(page).to have_content("TIK-XXX-39".to_s), count: 2
    expect(page).to have_content("Displayname".to_s), count: 2
    expect(page).to have_content('AXC'.to_s), count: 2
    expect(page).to have_content('CT_ID_0815'.to_s), count: 1
    expect(page).to have_content('CT_ID_0817'.to_s), count: 1
    expect(page).to have_content('000DF8072C67'.to_s), count: 1
    expect(page).to have_content('000DF8072C68'.to_s), count: 1
    expect(page).to have_content('127.0.0.5'.to_s), count: 1
    expect(page).to have_content('127.0.0.6'.to_s), count: 1
    expect(page).to have_content('true'.to_s), count: 2
    expect(page).to have_content('Raum U.16'.to_s), count: 2
    expect(page).to have_content('Der Hausmeister'.to_s), count: 2
    expect(page).to have_content('Dose 17/4, Patchfeld 5'.to_s), count: 2
    expect(page).to have_content('3.1.9'.to_s), count: 2
    expect(page).to have_content(Time.current.localtime.to_s.gsub(/\d\d \+.*/, '')), count: 4
  end
end
