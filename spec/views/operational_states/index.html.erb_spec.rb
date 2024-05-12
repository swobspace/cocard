require 'rails_helper'

RSpec.describe "operational_states/index", type: :view do
  before(:each) do
    assign(:operational_states, [
      OperationalState.create!(
        name: "Name",
        description: "Description"
      ),
      OperationalState.create!(
        name: "Name",
        description: "Description"
      )
    ])
  end

  it "renders a list of operational_states" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Description".to_s), count: 2
  end
end
