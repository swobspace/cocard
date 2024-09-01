require 'rails_helper'

RSpec.describe "notes/edit", type: :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'notes' }
    allow(controller).to receive(:action_name) { 'edit' }
    @notable = FactoryBot.create(:log, :with_connector)

    @note = assign(:note, FactoryBot.create(:note, notable: @notable))
  end

  it "renders the edit note form" do
    render

    assert_select "form[action=?][method=?]", log_note_path(@notable,@note), "post" do

      assert_select "input[name=?]", "note[valid_until]"

      assert_select "input[name=?]", "note[message]"
    end
  end
end
