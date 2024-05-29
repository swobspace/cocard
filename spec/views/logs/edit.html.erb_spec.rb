require 'rails_helper'

RSpec.describe "logs/edit", type: :view do
  let(:log) {
    Log.create!(
      loggable: nil,
      action: "MyString",
      level: "MyString",
      message: "MyText"
    )
  }

  before(:each) do
    assign(:log, log)
  end

  it "renders the edit log form" do
    render

    assert_select "form[action=?][method=?]", log_path(log), "post" do

      assert_select "input[name=?]", "log[loggable_id]"

      assert_select "input[name=?]", "log[action]"

      assert_select "input[name=?]", "log[level]"

      assert_select "textarea[name=?]", "log[message]"
    end
  end
end
