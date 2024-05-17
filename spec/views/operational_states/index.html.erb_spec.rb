require 'rails_helper'

RSpec.describe "operational_states/index", type: :view do
  before(:each) do
    assign(:operational_states, [
      OperationalState.create!(
        name: "Name1",
        description: "Description"
      ),
      OperationalState.create!(
        name: "Name2",
        description: "Description"
      )
    ])
  end

  it "renders a list of operational_states" do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new("Name1".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("Name2".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("Description".to_s), count: 2
  end
end