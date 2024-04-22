require 'rails_helper'

RSpec.describe "contexts/new", type: :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'contexts' }
    allow(controller).to receive(:action_name) { 'new' }

    assign(:context, FactoryBot.build(:context))
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
