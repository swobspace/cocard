require 'rails_helper'

RSpec.describe "connectors/index", type: :view do
  let(:location) { FactoryBot.create(:location, lid: 'AAC') }
  let(:client)   { FactoryBot.create(:client, name: 'Otto') }
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'connectors' }
    allow(controller).to receive(:action_name) { 'edit' }

    assign(:connectors, [
      Connector.create!(
        name: "Name",
        ip: "192.0.2.1",
        sds_url: "Sds Url",
        manual_update: false,
        client_ids: [client.id],
        location_ids: [location.id]
      ),
      Connector.create!(
        name: "Name",
        ip: "192.0.2.2",
        sds_url: "Sds Url",
        manual_update: false,
        client_ids: [client.id],
        location_ids: [location.id]
      )
    ])
  end

  it "renders a list of connectors" do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("192.0.2.1".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("192.0.2.2".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("Sds Url".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(false.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("AAC".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Otto".to_s), count: 2
  end
end
