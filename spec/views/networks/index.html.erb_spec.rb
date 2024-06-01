require 'rails_helper'

RSpec.describe "networks/index", type: :view do
  let(:location) { FactoryBot.create(:location, lid: 'AXC') }
  before(:each) do
    assign(:networks, [
      FactoryBot.create(:network, netzwerk: '198.51.100.128/29',
                        location: location, description: "some more information"),
      FactoryBot.create(:network, netzwerk: '198.51.100.136/29',
                        location: location, description: "some more information"),
    ])
  end

  it "renders a list of networks" do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new("198.51.100.128/29".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("198.51.100.136/29".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("some more information".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("AXC".to_s), count: 2
  end
end
