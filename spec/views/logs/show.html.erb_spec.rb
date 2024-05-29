require 'rails_helper'

RSpec.describe "logs/show", type: :view do
  let(:conn) { FactoryBot.create(:connector, name: 'TK-AXC-04') }
  let(:ts)   { Time.current }
  before(:each) do
    assign(:log, Log.create!(
      loggable: conn,
      action: "Action",
      level: "Level",
      message: "MyText",
      last_seen: ts
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/TK-AXC-04/)
    expect(rendered).to match(/Action/)
    expect(rendered).to match(/Level/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match("#{ts.localtime.to_s.gsub(/\+.*/, '')}")
  end
end
