require 'rails_helper'

RSpec.describe "tags/show", type: :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    @ability.can :manage, Tag
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'tags' }
    allow(controller).to receive(:action_name) { 'new' }

    assign(:tag, Tag.create!(
      name: "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
