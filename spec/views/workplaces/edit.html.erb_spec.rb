require 'rails_helper'

RSpec.describe "workplaces/edit", type: :view do
  let(:workplace) {
    Workplace.create!(
      description: nil
    )
  }

  before(:each) do
    assign(:workplace, workplace)
  end

  it "renders the edit workplace form" do
    render

    assert_select "form[action=?][method=?]", workplace_path(workplace), "post" do

      assert_select "input[name=?]", "workplace[description]"
    end
  end
end
