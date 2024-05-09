require 'rails_helper'

RSpec.describe "/cards", type: :request do
  let(:ct) { FactoryBot.create(:card_terminal) }
  let(:valid_attributes) {
    FactoryBot.attributes_for(:card)
  }

  let(:invalid_attributes) {
    { iccsn: nil }
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

  describe "GET /new" do
    it "renders a successful response" do
      get new_card_url
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

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Card" do
        expect {
          post cards_url, params: { card: valid_attributes }
        }.to change(Card, :count).by(1)
      end

      it "redirects to the created card" do
        post cards_url, params: { card: valid_attributes }
        expect(response).to redirect_to(card_url(Card.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Card" do
        expect {
          post cards_url, params: { card: invalid_attributes }
        }.to change(Card, :count).by(0)
      end


      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post cards_url, params: { card: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {{
        name: "MyCard",
        description: "some additional text",
        card_terminal_id: ct.id,
        iccsn: "8027912345678",
        card_holder_name: "Meister Quant",
        card_type: "HBA",
        slotid: 2222,
      }}

      it "updates the requested card" do
        card = Card.create! valid_attributes
        patch card_url(card), params: { card: new_attributes }
        card.reload
        expect(card.name).to eq("MyCard")
        expect(card.description.to_plain_text).to eq("some additional text")
        expect(card.card_terminal).to eq(ct)
        expect(card.iccsn).to eq("8027912345678")
        expect(card.card_holder_name).to eq("Meister Quant")
        expect(card.card_type).to eq("HBA")
        expect(card.slotid).to eq(2222)
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
