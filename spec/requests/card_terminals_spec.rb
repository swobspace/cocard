require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe "/card_terminals", type: :request do
  
  # This should return the minimal set of attributes required to create a valid
  # CardTerminal. As you add validations to CardTerminal, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  describe "GET /index" do
    it "renders a successful response" do
      CardTerminal.create! valid_attributes
      get card_terminals_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      card_terminal = CardTerminal.create! valid_attributes
      get card_terminal_url(card_terminal)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_card_terminal_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      card_terminal = CardTerminal.create! valid_attributes
      get edit_card_terminal_url(card_terminal)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new CardTerminal" do
        expect {
          post card_terminals_url, params: { card_terminal: valid_attributes }
        }.to change(CardTerminal, :count).by(1)
      end

      it "redirects to the created card_terminal" do
        post card_terminals_url, params: { card_terminal: valid_attributes }
        expect(response).to redirect_to(card_terminal_url(CardTerminal.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new CardTerminal" do
        expect {
          post card_terminals_url, params: { card_terminal: invalid_attributes }
        }.to change(CardTerminal, :count).by(0)
      end

    
      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post card_terminals_url, params: { card_terminal: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested card_terminal" do
        card_terminal = CardTerminal.create! valid_attributes
        patch card_terminal_url(card_terminal), params: { card_terminal: new_attributes }
        card_terminal.reload
        skip("Add assertions for updated state")
      end

      it "redirects to the card_terminal" do
        card_terminal = CardTerminal.create! valid_attributes
        patch card_terminal_url(card_terminal), params: { card_terminal: new_attributes }
        card_terminal.reload
        expect(response).to redirect_to(card_terminal_url(card_terminal))
      end
    end

    context "with invalid parameters" do
    
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        card_terminal = CardTerminal.create! valid_attributes
        patch card_terminal_url(card_terminal), params: { card_terminal: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested card_terminal" do
      card_terminal = CardTerminal.create! valid_attributes
      expect {
        delete card_terminal_url(card_terminal)
      }.to change(CardTerminal, :count).by(-1)
    end

    it "redirects to the card_terminals list" do
      card_terminal = CardTerminal.create! valid_attributes
      delete card_terminal_url(card_terminal)
      expect(response).to redirect_to(card_terminals_url)
    end
  end
end
