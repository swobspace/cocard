require 'rails_helper'

RSpec.describe "ti_clients/show", type: :view do
  let(:conn) { FactoryBot.create(:connector, name: 'Konn1') }
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    @ability.can :manage, KTProxy
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'ti_clients' }
    allow(controller).to receive(:action_name) { 'show' }

    assign(:ti_client, TIClient.create!(
      connector: conn,
      name: "Name",
      url: "Url",
      client_secret: "StrengGeheim"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Konn1/)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Url/)
    expect(rendered).to match(/vorhanden/)
  end
end
