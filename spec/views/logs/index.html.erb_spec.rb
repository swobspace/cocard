require 'rails_helper'

RSpec.describe "logs/index", type: :view do
  let(:conn) { FactoryBot.create(:connector, name: 'TK-AXC-04') }
  let(:ts)   { Time.current }
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'logs' }
    allow(controller).to receive(:action_name) { 'index' }

    assign(:logs, [
      Log.create!(
        loggable: conn,
        action: "Action",
        level: "Level",
        message: "MyText",
        last_seen: ts
      ),
      Log.create!(
        loggable: conn,
        action: "Action",
        level: "Level",
        message: "MyText",
        last_seen: ts
      )
    ])
  end

  it "renders a list of logs" do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new("TK-AXC-04".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Action".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Level".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(ts.localtime.to_s.gsub(/\+.*/, '')), count: 4
  end
end
