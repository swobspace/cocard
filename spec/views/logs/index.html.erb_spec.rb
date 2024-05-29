require 'rails_helper'

RSpec.describe "logs/index", type: :view do
  before(:each) do
    assign(:logs, [
      Log.create!(
        loggable: nil,
        action: "Action",
        level: "Level",
        message: "MyText"
      ),
      Log.create!(
        loggable: nil,
        action: "Action",
        level: "Level",
        message: "MyText"
      )
    ])
  end

  it "renders a list of logs" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Action".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Level".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
  end
end
