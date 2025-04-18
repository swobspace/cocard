require 'rails_helper'

RSpec.describe "cards/edit", type: :view do
  let(:card) do
    FactoryBot.create(:card,
      name: "MyString",
      card_type: 'SMC-B'
    )
  end

  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'cards' }
    allow(controller).to receive(:action_name) { 'edit' }
    assign(:card, card)
  end

  it "renders the edit card form" do
    render

    assert_select "form[action=?][method=?]", card_path(card), "post" do

      assert_select "input[name=?]", "card[name]"
      assert_select "input[name=?]", "card[description]"
      assert_select "input[name=?]", "card[card_type]"
      assert_select "input[name=?]", "card[card_holder_name]"
      assert_select "input[name=?]", "card[iccsn]"
      assert_select "select[name=?]", "card[location_id]"
      assert_select "select[name=?]", "card[operational_state_id]"
      assert_select "input[name=?]", "card[lanr]"
      assert_select "input[name=?]", "card[bsnr]"
      assert_select "input[name=?]", "card[telematikid]"
      assert_select "input[name=?]", "card[fachrichtung]"
      assert_select "input[name=?]", "card[private_information]"
      assert_select "input[name=?]", "card[expiration_date]"
      assert_select "input[name=?]", "card[cert_subject_title]"
      assert_select "input[name=?]", "card[cert_subject_sn]"
      assert_select "input[name=?]", "card[cert_subject_givenname]"
      assert_select "input[name=?]", "card[cert_subject_street]"
      assert_select "input[name=?]", "card[cert_subject_postalcode]"
      assert_select "input[name=?]", "card[cert_subject_l]"
      assert_select "input[name=?]", "card[cert_subject_cn]"
      assert_select "input[name=?]", "card[cert_subject_o]"
    end
  end
end
