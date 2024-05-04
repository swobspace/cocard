require 'rails_helper'

RSpec.describe "cards/edit", type: :view do
  let(:card) do
    FactoryBot.create(:card,
      name: "MyString"
    )
  end

  before(:each) do
    assign(:card, card)
  end

  it "renders the edit card form" do
    render

    assert_select "form[action=?][method=?]", card_path(card), "post" do

      assert_select "input[name=?]", "card[name]"
      assert_select "input[name=?]", "card[description]"
    end
  end
end
