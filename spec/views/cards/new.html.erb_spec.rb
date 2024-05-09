require 'rails_helper'

RSpec.describe "cards/new", type: :view do
  let(:card) do
    FactoryBot.build(:card,
      name: "MyString"
    )
  end

  before(:each) do
    assign(:card, card)
  end

  it "renders the new card form" do
    render

    assert_select "form[action=?][method=?]", cards_path, "post" do

      assert_select "input[name=?]", "card[name]"
      assert_select "input[name=?]", "card[description]"
      assert_select "input[name=?]", "card[card_type]"
      assert_select "input[name=?]", "card[slotid]"
      assert_select "input[name=?]", "card[card_holder_name]"
      assert_select "select[name=?]", "card[card_terminal_id]"
      assert_select "input[name=?]", "card[iccsn]" do |input|
        assert input.attr("disabled").blank?
      end
    end
  end
end
