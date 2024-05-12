require 'rails_helper'

RSpec.describe "operational_states/edit", type: :view do
  let(:operational_state) {
    OperationalState.create!(
      name: "MyString",
      description: "MyString"
    )
  }

  before(:each) do
    assign(:operational_state, operational_state)
  end

  it "renders the edit operational_state form" do
    render

    assert_select "form[action=?][method=?]", operational_state_path(operational_state), "post" do

      assert_select "input[name=?]", "operational_state[name]"

      assert_select "input[name=?]", "operational_state[description]"
    end
  end
end
