require 'rails_helper'

RSpec.describe "operational_states/index", type: :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'operational_states' }
    allow(controller).to receive(:action_name) { 'index' }

    assign(:operational_states, [
      OperationalState.create!(
        name: "Name1",
        description: "Description",
        operational: true
      ),
      OperationalState.create!(
        name: "Name2",
        description: "Description",
        operational: false
      )
    ])
  end

  it "renders a list of operational_states" do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new("Name1".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("Name2".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("Description".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("true".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("false".to_s), count: 1
  end
end
