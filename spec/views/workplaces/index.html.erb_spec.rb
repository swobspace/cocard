require 'rails_helper'

RSpec.describe "workplaces/index", type: :view do
  before(:each) do
    assign(:workplaces, [
      Workplace.create!(
        name: 'NB-AXC-0004',
        description: "some more information"
      ),
      Workplace.create!(
        name: 'NB-AXC-0005',
        description: "some more information"
      )
    ])
  end

  it "renders a list of workplaces" do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new("NB-AXC-0004".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("NB-AXC-0005".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("some more information".to_s), count: 2
  end
end
