require 'rails_helper'

RSpec.describe "oids/show", type: :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    @ability.can :manage, Tag
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'oids' }
    allow(controller).to receive(:action_name) { 'show' }

    assign(:oid, Oid.create!(
      oid: "2.3.4.5.6.99",
      name: "Name",
      reference: "Reference"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2.3.4.5.6.99/)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Reference/)
  end
end
