require 'rails_helper'

RSpec.describe "oids/index", type: :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    @ability.can :manage, Tag
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'oids' }
    allow(controller).to receive(:action_name) { 'index' }

    assign(:oids, [
      Oid.create!(
        oid: "2.3.4.5.6.99",
        name: "Name1",
        reference: "Reference1"
      ),
      Oid.create!(
        oid: "2.3.4.5.6.100",
        name: "Name2",
        reference: "Reference2"
      )
    ])
  end

  it "renders a list of oids" do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new("2.3.4.5.6.99".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("Name1".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("Reference1".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("2.3.4.5.6.100".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("Name2".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("Reference2".to_s), count: 1
  end
end
