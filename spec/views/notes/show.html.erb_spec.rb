require 'rails_helper'

RSpec.describe "notes/show", type: :view do
  let(:user) { FactoryBot.create(:user) }
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'notes' }
    allow(controller).to receive(:action_name) { 'show' }
    @notable = FactoryBot.create(:log, :with_connector)

    @note = assign(:note, FactoryBot.create(:note,
              user_id: user.id,
              notable: @notable,
              valid_until: '2024-01-01',
              message: "some other text" 
            ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2024-01-01/)
    expect(rendered).to match(/some other text/)
  end
end
