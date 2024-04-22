require 'rails_helper'

RSpec.describe "contexts/index", type: :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'contexts' }
    allow(controller).to receive(:action_name) { 'index' }

    assign(:contexts, [
      Context.create!(
        mandant: "Mandant",
        client_system: "Client System1",
        workplace: "Workplace",
        description: "Description"
      ),
      Context.create!(
        mandant: "Mandant",
        client_system: "Client System2",
        workplace: "Workplace",
        description: "Description"
      )
    ])
  end

  it "renders a list of contexts" do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new("Mandant".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Client System1".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("Client System2".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("Workplace".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Description".to_s), count: 2
  end
end
