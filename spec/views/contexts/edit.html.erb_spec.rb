require 'rails_helper'

RSpec.describe "contexts/edit", type: :view do
  let(:context) { FactoryBot.create(:context) }

  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'contexts' }
    allow(controller).to receive(:action_name) { 'edit' }

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
