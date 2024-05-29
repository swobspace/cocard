require 'rails_helper'

RSpec.describe "logs/new", type: :view do
  before(:each) do
    assign(:log, Log.new(
      loggable: nil,
      action: "MyString",
      level: "MyString",
      message: "MyText"
    ))
  end

  it "renders new log form" do
    render

    assert_select "form[action=?][method=?]", logs_path, "post" do

      assert_select "input[name=?]", "log[loggable_id]"

      assert_select "input[name=?]", "log[action]"

      assert_select "input[name=?]", "log[level]"

      assert_select "textarea[name=?]", "log[message]"
    end
  end
end
