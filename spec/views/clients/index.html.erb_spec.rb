require 'rails_helper'

RSpec.describe "clients/index", type: :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'clients' }
    allow(controller).to receive(:action_name) { 'edit' }

    assign(:clients, [
      Client.create!(
        name: "Name1",
        description: "Description"
      ),
      Client.create!(
        name: "Name2",
        description: "Description"
      )
    ])
  end

  it "renders a list of clients" do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new("Name1".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("Name2".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("Description".to_s), count: 2
  end
end
