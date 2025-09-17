require 'rails_helper'

RSpec.describe "Location", type: :feature, js: true do
  let(:ts)        { Time.current }
  let(:location) do
    FactoryBot.create(:location, 
      lid: 'AXC', description: "some description"
    )
  end
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
    connector.locations << location; connector.reload
    visit location_path(location)
  end

  it "visit location_path" do
    expect(page).to have_content("some description")
    expect(page).to have_content("Der Hausmeister")
    expect(page).to have_content("Dose 17/4, Patchfeld 5")
    expect(page).to have_content("CT_ID_0815")
    expect(page).to have_content("TIK-XXX-39")
  end

end
