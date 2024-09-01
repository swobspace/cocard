require 'rails_helper'

RSpec.describe "notes/edit", type: :view do
  let(:note) {
    Note.create!(
      notable: nil,
      user: nil,
      type: 1,
      description: nil
    )
  }

  before(:each) do
    assign(:note, note)
  end

  it "renders the edit note form" do
    render

    assert_select "form[action=?][method=?]", note_path(note), "post" do

      assert_select "input[name=?]", "note[notable_id]"

      assert_select "input[name=?]", "note[user_id]"

      assert_select "input[name=?]", "note[type]"

      assert_select "input[name=?]", "note[description]"
    end
  end
end
