require 'rails_helper'

RSpec.describe "tags/index", type: :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    @ability.can :manage, Tag
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'tags' }
    allow(controller).to receive(:action_name) { 'new' }

    assign(:tags, [
      Tag.create!(
        name: "Name1"
      ),
      Tag.create!(
        name: "Name2"
      )
    ])
  end

  it "renders a list of tags" do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
  end
end
