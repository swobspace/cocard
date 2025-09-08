require 'rails_helper'

RSpec.describe "CardTerminals", type: :feature, js: true do
  let(:ts)        { Time.current }
  let(:location)  { FactoryBot.create(:location, lid: 'AXC') }
  let(:connector) { FactoryBot.create(:connector, name: 'TIK-XXX-39' ) }

  let!(:ct) do
    FactoryBot.create(:card_terminal,
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
    )
  end

  before(:each) do
    login_user(role: 'Admin')
    visit card_terminal_path(ct)
  end

  it "visit card_terminal_path" do
    expect(page).to have_content("Kartenterminal: ##{ct.id}")
    expect(page).to have_content("ORGA-DINGDONG001 (AXC)".to_s)
  end

  it "delete an existing terminal" do
    expect(page).to have_content("ORGA-DINGDONG001 (AXC)".to_s)
    expect(CardTerminal.count).to eq(1)
    accept_confirm do
      find('a[title="Kartenterminal löschen"]').click
    end
    within "#card_terminals" do
      expect(page).to have_content "0 bis 0 von 0 Einträgen"
    end
    expect(CardTerminal.count).to eq(0)
  end

  it "edit terminal" do
    find('a[title="Kartenterminal bearbeiten"]').click
    within "form#edit_card_terminal_#{ct.id}" do
      fill_in "Anzeigename", with: "Anderes Terminal 05"
      click_button("Kartenterminal aktualisieren")
    end
    # save_and_open_screenshot()
    expect(page).to have_content("Kartenterminal: ##{ct.id}")
    expect(page).to have_content("ORGA-DINGDONG001 (AXC)".to_s)
    expect(page).to have_content("Anderes Terminal 05")
  end

  it "add new card terminal" do
    visit new_card_terminal_path
    within "form#new_card_terminal" do
      fill_in "Anzeigename", with: "Neues Terminal 4711"
      fill_in "Seriennummer", with: "S-0123456789"
      click_button("Kartenterminal erstellen")
    end
    expect(page).to have_content("Kartenterminal erfolgreich erstellt")
    expect(page).to have_content("Kartenterminal: #")
    expect(page).to have_content("Neues Terminal 4711")
    expect(page).to have_content("S-0123456789")
    # save_and_open_screenshot()
    expect(page).to have_content("Terminal not connected!")
    expect(page).to have_content("Kein Konnektor zugewiesen")
  end
end
