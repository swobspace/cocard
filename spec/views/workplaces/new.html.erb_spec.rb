require 'rails_helper'

RSpec.describe "workplaces/new", type: :view do
  before(:each) do
    assign(:workplace, Workplace.new(
      description: nil
    ))
  end

  it "renders new workplace form" do
    render

    assert_select "form[action=?][method=?]", workplaces_path, "post" do

      assert_select "input[name=?]", "workplace[description]"
    end
  end
end
