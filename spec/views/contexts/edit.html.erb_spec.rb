require 'rails_helper'

RSpec.describe "contexts/edit", type: :view do
  let(:context) {
    Context.create!(
      mandant: "MyString",
      client_system: "MyString",
      workplace: "MyString",
      description: "MyString"
    )
  }

  before(:each) do
    assign(:context, context)
  end

  it "renders the edit context form" do
    render

    assert_select "form[action=?][method=?]", context_path(context), "post" do

      assert_select "input[name=?]", "context[mandant]"

      assert_select "input[name=?]", "context[client_system]"

      assert_select "input[name=?]", "context[workplace]"

      assert_select "input[name=?]", "context[description]"
    end
  end
end
