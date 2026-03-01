require 'rails_helper'

RSpec.describe CardTerminals::CardTerminalSlotsController, type: :request do
  
  let(:ct) { FactoryBot.create(:card_terminal, :with_mac) }
  let(:card) { FactoryBot.create(:card, card_type: 'SMC-B') }
  let(:valid_attributes) {
    FactoryBot.attributes_for(:card_terminal_slot, card_terminal_id: ct.id)
  }

  let(:invalid_attributes) {
    { slotid: nil }
  }

  before(:each) do
    login_admin
  end

  describe "GET /index" do
    it "renders a successful response" do
      CardTerminalSlot.create! valid_attributes
      get card_terminal_card_terminal_slots_url(ct)
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      card_terminal_slot = CardTerminalSlot.create! valid_attributes
      get card_terminal_card_terminal_slot_url(ct, card_terminal_slot)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_card_terminal_card_terminal_slot_url(ct)
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      card_terminal_slot = CardTerminalSlot.create! valid_attributes
      get edit_card_terminal_card_terminal_slot_url(ct,card_terminal_slot)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new CardTerminalSlot" do
        expect {
          post card_terminal_card_terminal_slots_url(ct), 
               params: { card_terminal_slot: valid_attributes }
        }.to change(CardTerminalSlot, :count).by(1)
      end

      it "redirects to the created card_terminal_slot" do
        post card_terminal_card_terminal_slots_url(ct), params: { card_terminal_slot: valid_attributes }
        expect(response).to redirect_to(card_terminal_card_terminal_slot_url(ct, CardTerminalSlot.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new CardTerminalSlot" do
        expect {
          post card_terminal_card_terminal_slots_url(ct), params: { card_terminal_slot: invalid_attributes }
        }.to change(CardTerminalSlot, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post card_terminal_card_terminal_slots_url(ct), params: { card_terminal_slot: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { slotid: 17 }
      }

      it "updates the requested card_terminal_slot" do
        card_terminal_slot = CardTerminalSlot.create! valid_attributes
        patch card_terminal_card_terminal_slot_url(ct,card_terminal_slot), params: { card_terminal_slot: new_attributes }
        card_terminal_slot.reload
        expect(card_terminal_slot.slotid).to eq(17)
      end

      it "redirects to the card_terminal_slot" do
        card_terminal_slot = CardTerminalSlot.create! valid_attributes
        patch card_terminal_card_terminal_slot_url(ct,card_terminal_slot), params: { card_terminal_slot: new_attributes }
        card_terminal_slot.reload
        expect(response).to redirect_to(card_terminal_card_terminal_slot_url(ct,card_terminal_slot))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        card_terminal_slot = CardTerminalSlot.create! valid_attributes
        patch card_terminal_card_terminal_slot_url(ct, card_terminal_slot), params: { card_terminal_slot: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested card_terminal_slot" do
      card_terminal_slot = CardTerminalSlot.create! valid_attributes
      expect {
        delete card_terminal_card_terminal_slot_url(ct,card_terminal_slot)
      }.to change(CardTerminalSlot, :count).by(-1)
    end

    it "redirects to the card_terminal_slots list" do
      card_terminal_slot = CardTerminalSlot.create! valid_attributes
      delete card_terminal_card_terminal_slot_url(ct,card_terminal_slot)
      expect(response).to redirect_to(card_terminal_card_terminal_slots_url(ct))
    end
  end
end
