require 'rails_helper'

RSpec.describe "notes/new", type: :view do
  before(:each) do
    assign(:note, Note.new(
      notable: nil,
      user: nil,
      type: 1,
      description: nil
    ))
  end

  it "renders new note form" do
    render

    assert_select "form[action=?][method=?]", notes_path, "post" do

      assert_select "input[name=?]", "note[notable_id]"

      assert_select "input[name=?]", "note[user_id]"

      assert_select "input[name=?]", "note[type]"

      assert_select "input[name=?]", "note[description]"
    end
  end
end
