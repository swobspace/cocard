require 'rails_helper'

RSpec.describe "ti_clients/index", type: :view do
  let(:conn1) { FactoryBot.create(:connector, name: 'Konn1') }
  let(:conn2) { FactoryBot.create(:connector, name: 'Konn2') }
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    @ability.can :manage, KTProxy
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'ti_clients' }
    allow(controller).to receive(:action_name) { 'index' }

    assign(:ti_clients, [
      TIClient.create!(
        connector: conn1,
        name: "Name",
        url: "Url1"
      ),
      TIClient.create!(
        connector: conn2,
        name: "Name",
        url: "Url2"
      )
    ])
  end

  it "renders a list of ti_clients" do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new("Konn1".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("Konn2".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Url1".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("Url2".to_s), count: 1
  end
end
