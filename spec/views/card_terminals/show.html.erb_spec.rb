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
      ip: "192.0.2.31",
      connected: true,
      condition: Cocard::States::OK
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
    expect(rendered).to match(/192.0.2.31/)
    expect(rendered).to match(/true/)
    expect(rendered).to match(/OK/)
  end
end