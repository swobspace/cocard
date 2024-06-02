require 'rails_helper'

RSpec.describe "workplaces/new", type: :view do
  before(:each) do
    assign(:workplace, Workplace.new(
      name: "NB-AXC-0004",
      description: "some text"
    ))
  end

  it "renders new workplace form" do
    render

    assert_select "form[action=?][method=?]", workplaces_path, "post" do
      assert_select "input[name=?]", "workplace[name]" do |input|
        assert input.attr("disabled").present?
      end
      assert_select "input[name=?]", "workplace[description]"
    end
  end
end
