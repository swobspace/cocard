require 'rails_helper'

RSpec.describe "locations/index", type: :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'locations' }
    allow(controller).to receive(:action_name) { 'index' }

    assign(:locations, [
      Location.create!(
        lid: "Lid1",
        description: "Description"
      ),
      Location.create!(
        lid: "Lid2",
        description: "Description"
      )
    ])
  end

  it "renders a list of locations" do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new("Lid1".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("Lid2".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("Description".to_s), count: 2
  end
end
