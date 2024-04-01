require 'rails_helper'

RSpec.describe "locations/edit", type: :view do
  let(:location) {
    Location.create!(
      lid: "MyString",
      description: "MyString"
    )
  }

  before(:each) do
    assign(:location, location)
  end

  it "renders the edit location form" do
    render

    assert_select "form[action=?][method=?]", location_path(location), "post" do

      assert_select "input[name=?]", "location[lid]"

      assert_select "input[name=?]", "location[description]"
    end
  end
end
