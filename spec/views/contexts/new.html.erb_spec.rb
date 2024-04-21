require 'rails_helper'

RSpec.describe "contexts/new", type: :view do
  before(:each) do
    assign(:context, Context.new(
      mandant: "MyString",
      client_system: "MyString",
      workplace: "MyString",
      description: "MyString"
    ))
  end

  it "renders new context form" do
    render

    assert_select "form[action=?][method=?]", contexts_path, "post" do

      assert_select "input[name=?]", "context[mandant]"

      assert_select "input[name=?]", "context[client_system]"

      assert_select "input[name=?]", "context[workplace]"

      assert_select "input[name=?]", "context[description]"
    end
  end
end
