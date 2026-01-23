require 'rails_helper'

RSpec.describe "tags/new", type: :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    @ability.can :manage, Tag
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'tags' }
    allow(controller).to receive(:action_name) { 'new' }

    assign(:tag, FactoryBot.build(:tag))
  end

  it "renders new tag form" do
    render

    assert_select "form[action=?][method=?]", tags_path, "post" do

      assert_select "input[name=?]", "tag[name]"
    end
  end
end
