require 'rails_helper'

RSpec.describe "operational_states/new", type: :view do
  before(:each) do
    assign(:operational_state, OperationalState.new(
      name: "MyString",
      description: "MyString"
    ))
  end

  it "renders new operational_state form" do
    render

    assert_select "form[action=?][method=?]", operational_states_path, "post" do

      assert_select "input[name=?]", "operational_state[name]"

      assert_select "input[name=?]", "operational_state[description]"
    end
  end
end
