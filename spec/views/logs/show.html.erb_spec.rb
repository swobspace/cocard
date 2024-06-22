require 'rails_helper'

RSpec.describe "logs/show", type: :view do
  let(:conn) { FactoryBot.create(:connector, name: 'TK-AXC-04') }
  let(:ts)   { Time.current }
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'logs' }
    allow(controller).to receive(:action_name) { 'show' }

    assign(:log, Log.create!(
      loggable: conn,
      action: "Action",
      level: "Level",
      message: "MyText",
      is_valid: true,
      condition: 3,
      last_seen: ts
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/TK-AXC-04/)
    expect(rendered).to match(/Action/)
    expect(rendered).to match(/Level/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/true/)
    expect(rendered).to match(/UNKNOWN/)
    expect(rendered).to match("#{ts.localtime.to_s.gsub(/\+.*/, '')}")
  end
end
