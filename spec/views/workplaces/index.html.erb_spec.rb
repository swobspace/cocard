require 'rails_helper'

RSpec.describe "workplaces/index", type: :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'workplaces' }
    allow(controller).to receive(:action_name) { 'index' }

    assign(:workplaces, [
      Workplace.create!(
        name: 'NB-AXC-0004',
        description: "some more information",
        last_seen: 7.days.before(Time.current)
      ),
      Workplace.create!(
        name: 'NB-AXC-0005',
        description: "some more information",
        last_seen: 7.days.before(Time.current)
      )
    ])
  end

  it "renders a list of workplaces" do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new("NB-AXC-0004".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("NB-AXC-0005".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("some more information".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("⚠ 7 day".to_s), count: 2
  end
end
