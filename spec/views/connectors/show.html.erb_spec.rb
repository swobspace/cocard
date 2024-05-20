require 'rails_helper'

RSpec.describe "connectors/show", type: :view do
  let(:current) { Time.current }
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'connectors' }
    allow(controller).to receive(:action_name) { 'show' }

    assign(:connector, Connector.create!(
      name: "Name",
      ip: "192.0.2.1",
      sds_url: "Sds Url",
      manual_update: false,
      description: "some text",
      last_check: current,
      last_check_ok: current,
      firmware_version: "123.456"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/192.0.2.1/)
    expect(rendered).to match(/Sds Url/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/some text/)
    expect(rendered).to match(/#{current.localtime.to_s.gsub('+', '.')}/)
    expect(rendered).to match(/123.456/)
  end
end
