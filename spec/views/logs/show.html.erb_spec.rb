require 'rails_helper'

RSpec.describe "logs/show", type: :view do
  before(:each) do
    assign(:log, Log.create!(
      loggable: nil,
      action: "Action",
      level: "Level",
      message: "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Action/)
    expect(rendered).to match(/Level/)
    expect(rendered).to match(/MyText/)
  end
end
