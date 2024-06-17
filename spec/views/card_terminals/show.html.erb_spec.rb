require 'rails_helper'

RSpec.describe "card_terminals/show", type: :view do
  let(:ts)        { Time.current }
  let(:location)  { FactoryBot.create(:location, lid: 'AXC') }
  let(:connector) { FactoryBot.create(:connector) }
  let(:prodinfo)  {{ product_information:
    {:information_date=> ts,
     :product_type_information=> {:product_type=>"KardTerm", :product_type_version=>"1.2.3.4"},
     :product_identification=> {
       :product_vendor_id=>"Heinrich GmbH",
       :product_code=>nil,
       :product_version=> { :local=>{:hw_version=>"5.6.7", :fw_version=>"8.9.1"}}
     },
     :product_miscellaneous=> {:product_vendor_name=>nil, :product_name=>nil}}
  }}

  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'card_terminals' }
    allow(controller).to receive(:action_name) { 'show' }

    # assign(:card_terminal, CardTerminal.create!(
    @card_terminal = CardTerminal.create!(
      connector_id: connector.id,
      displayname: "Displayname",
      description: "some other text",
      location_id: location.id,
      properties: prodinfo,
      name: "ORGA-DINGDONG001",
      ct_id: "CT_ID0815",
      mac: "00-0D-F8-07-2C-67",
      ip: "127.0.0.5",
      connected: true,
      condition: Cocard::States::UNKNOWN,
      room: "Raum U.16",
      contact: "Der Hausmeister",
      supplier: 'ACME Ltd',
      delivery_date: '2023-12-14',
      firmware_version: '3.1.9',
      plugged_in: "Dose 17/4, Patchfeld 5",
      serial: '11122277634',
      id_product: 'ORGA61411'
    )
  end

  it "renders attributes in <p>" do
    # pp Cocard::ProductInformation.new(@card_terminal.properties).product_type_information
    render
    expect(rendered).to match(/Displayname/)
    expect(rendered).to match(/AXC/)
    expect(rendered).to match(/some other text/)
    expect(rendered).to match(/KardTerm/)
    expect(rendered).to match(/1.2.3.4/)
    expect(rendered).to match(/Heinrich GmbH/)
    expect(rendered).to match(/5.6.7/)
    expect(rendered).to match(/8.9.1/)
    expect(rendered).to match(/ORGA-DINGDONG001/)
    expect(rendered).to match(/CT_ID0815/)
    expect(rendered).to match(/00-0D-F8-07-2C-67/)
    expect(rendered).to match(/127.0.0.5/)
    expect(rendered).to match(/true/)
    # -- should be OK with connected == true and pingable
    expect(rendered).to match(/OK/)
    expect(rendered).to match(/Raum U.16/)
    expect(rendered).to match(/Der Hausmeister/)
    expect(rendered).to match(/Dose 17\/4, Patchfeld 5/)
    expect(rendered).to match(/2023-12-14/)
    expect(rendered).to match(/ACME Ltd/)
    expect(rendered).to match(/3.1.9/)
    expect(rendered).to match(/ORGA6141/)
    expect(rendered).to match(/11122277634/)

  end
end
