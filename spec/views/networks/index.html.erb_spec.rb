require 'rails_helper'

RSpec.describe "networks/index", type: :view do
  before(:each) do
    assign(:networks, [
      Network.create!(
        netzwerk: "",
        description: nil,
        location: nil
      ),
      Network.create!(
        netzwerk: "",
        description: nil,
        location: nil
      )
    ])
  end

  it "renders a list of networks" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new("".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
