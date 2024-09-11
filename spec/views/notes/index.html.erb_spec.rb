require 'rails_helper'

RSpec.describe "notes/index", type: :view do
  let(:user) { FactoryBot.create(:user) }
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability } 
    allow(controller).to receive(:controller_name) { 'notes' }
    allow(controller).to receive(:action_name) { 'index' }
    @notable = FactoryBot.create(:log, :with_connector)

    assign(:notes, [
      FactoryBot.create(:note,
        user_id: user.id,
        notable: @notable,
        valid_until: '2024-01-01',
        message: "some other text" 
      ),
      FactoryBot.create(:note,
        user_id: user.id,
        notable: @notable,
        valid_until: '2024-01-01',
        message: "some other text" 
      ),
    ])
  end

  it "renders a list of notes" do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new(@notable.to_s), count: 2
    assert_select cell_selector, text: Regexp.new('2024-01-01'.to_s), count: 2
    assert_select 'div.trix-content', text: Regexp.new('some other text'.to_s), count: 2
  end
end
