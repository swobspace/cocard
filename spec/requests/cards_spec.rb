require 'rails_helper'

RSpec.describe "/cards", type: :request do
  let(:ct) { FactoryBot.create(:card_terminal, :with_mac) }
  let(:context) { FactoryBot.create(:context) }
  let(:ops) { FactoryBot.create(:operational_state, name: "roquefort") }
  let(:location) { FactoryBot.create(:location, lid: "AXXC") }
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
      card = Card.create! valid_attributes.merge({card_type: 'SMC-B'})
      get card_url(card)
      expect(response).to be_successful
      expect(flash[:notice]).to match(/Es ist noch kein Kontext zugeordnet!/)
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
        iccsn: "8027912345678",
        card_holder_name: "Meister Quant",
        card_type: "HBA",
        operational_state_id: ops.id,
        location_id: location.id,
        lanr: "999777333",
        bsnr: "222444666",
        telematikid: "1-2-3-456",
        fachrichtung: "Innere Medizin",
        private_information: "some private information",
        context_ids: [context.id],
        cert_subject_title: 'CERT title',
        cert_subject_sn: 'CERT sn',
        cert_subject_givenname: 'CERT givenname',
        cert_subject_street: 'CERT street',
        cert_subject_postalcode: 'CERT postalcode',
        cert_subject_l: 'CERT l',
        cert_subject_o: 'CERT o',
        cert_subject_cn: 'CERT cn',
        expiration_date: '2024-12-31',
        card_contexts_attributes: [
          context_id: context.id,
        ]

      }}

      it "updates the requested card" do
        card = Card.create! valid_attributes
        patch card_url(card), params: { card: new_attributes }
        card.reload
        expect(card.name).to eq("MyCard")
        expect(card.description.to_plain_text).to eq("some additional text")
        expect(card.iccsn).to eq("8027912345678")
        expect(card.card_holder_name).to eq("Meister Quant")
        expect(card.card_type).to eq("HBA")
        expect(card.operational_state).to eq(ops)
        expect(card.location).to eq(location)
        expect(card.lanr).to eq("999777333")
        expect(card.bsnr).to eq("222444666")
        expect(card.telematikid).to eq("1-2-3-456")
        expect(card.fachrichtung).to eq("Innere Medizin")
        expect(card.private_information.to_plain_text).to eq("some private information")
        expect(card.contexts).to contain_exactly(context)
        expect(card.cert_subject_title).to eq('CERT title')
        expect(card.cert_subject_sn).to eq('CERT sn')
        expect(card.cert_subject_givenname).to eq('CERT givenname')
        expect(card.cert_subject_street).to eq('CERT street')
        expect(card.cert_subject_postalcode).to eq('CERT postalcode')
        expect(card.cert_subject_l).to eq('CERT l')
        expect(card.cert_subject_cn).to eq('CERT cn')
        expect(card.cert_subject_o).to eq('CERT o')
        expect(card.expiration_date.to_s).to eq('2024-12-31')
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
