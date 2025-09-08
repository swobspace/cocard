require 'rails_helper'

RSpec.describe "ti_clients/index", type: :view do
  before(:each) do
    assign(:ti_clients, [
      TIClient.create!(
        connector: nil,
        name: "Name",
        url: "Url"
      ),
      TIClient.create!(
        connector: nil,
        name: "Name",
        url: "Url"
      )
    ])
  end

  it "renders a list of ti_clients" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Url".to_s), count: 2
  end
end
