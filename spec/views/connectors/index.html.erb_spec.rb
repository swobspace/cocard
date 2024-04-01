require 'rails_helper'

RSpec.describe "connectors/index", type: :view do
  before(:each) do
    assign(:connectors, [
      Connector.create!(
        name: "Name",
        ip: "",
        sds_url: "Sds Url",
        manual_update: false
      ),
      Connector.create!(
        name: "Name",
        ip: "",
        sds_url: "Sds Url",
        manual_update: false
      )
    ])
  end

  it "renders a list of connectors" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Sds Url".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(false.to_s), count: 2
  end
end
