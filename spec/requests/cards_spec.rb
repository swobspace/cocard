require 'rails_helper'

RSpec.describe "/cards", type: :request do
  let(:ct) { FactoryBot.create(:card_terminal) }
  
  let(:valid_attributes) {
    FactoryBot.attributes_for(:card, card_terminal_id: ct.id)
  }

  let(:invalid_attributes) {
    { }
  }

  before(:each) do
    login_admin
  end

  describe "GET /index" do
    it "renders a successful response" do
      Card.create! valid_attributes
      get cards_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      card = Card.create! valid_attributes
      get card_url(card)
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      card = Card.create! valid_attributes
      get edit_card_url(card)
      expect(response).to be_successful
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {{
        name: "MyCard",
        description: "some additional text"
      }}

      it "updates the requested card" do
        card = Card.create! valid_attributes
        patch card_url(card), params: { card: new_attributes }
        card.reload
        expect(card.name).to eq("MyCard")
        expect(card.description.to_plain_text).to eq("some additional text")
      end

      it "redirects to the card" do
        card = Card.create! valid_attributes
        patch card_url(card), params: { card: new_attributes }
        card.reload
        expect(response).to redirect_to(card_url(card))
      end
    end

    context "with invalid parameters" do
    
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        skip "no invalid attributes yet possible"
        card = Card.create! valid_attributes
        patch card_url(card), params: { card: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested card" do
      card = Card.create! valid_attributes
      expect {
        delete card_url(card)
      }.to change(Card, :count).by(-1)
    end

    it "redirects to the cards list" do
      card = Card.create! valid_attributes
      delete card_url(card)
      expect(response).to redirect_to(cards_url)
    end
  end
end
