require 'rails_helper'
module Logs
  RSpec.describe "/notes", type: :request do
    let(:card) { FactoryBot.create(:card) }
    let(:user) { FactoryBot.create(:user) }

    let(:valid_attributes) {
      FactoryBot.attributes_for(:note, notable: card, user_id: user.id)
    }

    let(:invalid_attributes) {
      { message: nil }
    }

    before(:each) do
      login_admin
    end

    describe "GET /index" do
      it "renders a successful response" do
        Note.create! valid_attributes
        get card_notes_url(card)
        expect(response).to be_successful
      end
    end

    describe "GET /show" do
      it "renders a successful response" do
        note = Note.create! valid_attributes
        get card_note_url(card, note)
        expect(response).to be_successful
      end
    end

    describe "GET /new" do
      it "renders a successful response" do
        get new_card_note_url(card)
        expect(response).to be_successful
      end
    end

    describe "GET /edit" do
      it "renders a successful response" do
        note = Note.create! valid_attributes
        get edit_card_note_url(card,note)
        expect(response).to be_successful
      end
    end

    describe "POST /create" do
      context "with valid parameters" do
        it "creates a new Note" do
          expect {
            post card_notes_url(card), params: { note: valid_attributes }
          }.to change(Note, :count).by(1)
        end

        it "redirects to the created note" do
          post card_notes_url(card), params: { note: valid_attributes }
          skip "broadcasts refresh"
          expect(response).to redirect_to(note_url(Note.last))
        end
      end

      context "with invalid parameters" do
        it "does not create a new Note" do
          expect {
            post card_notes_url(card), params: { note: invalid_attributes }
          }.to change(Note, :count).by(0)
        end

      
        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          post card_notes_url(card), params: { note: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      
      end
    end

    describe "PATCH /update" do
      context "with valid parameters" do
        let(:new_attributes) {{
          valid_until: '2024-01-01'
        }}

        it "updates the requested note" do
          note = Note.create! valid_attributes
          patch card_note_url(card,note), params: { note: new_attributes }
          note.reload
          expect(note.valid_until.to_s).to eq('2024-01-01 00:00:00 UTC')
        end

        it "redirects to the note" do
          note = Note.create! valid_attributes
          patch card_note_url(card,note), params: { note: new_attributes }
          note.reload
          skip "broadcasts refresh"
          expect(response).to redirect_to(note_url(note))
        end
      end

      context "with invalid parameters" do
      
        it "renders a response with 422 status (i.e. to display the 'edit' template)" do
          note = Note.create! valid_attributes
          patch card_note_url(card,note), params: { note: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      
      end
    end

    describe "DELETE /destroy" do
      it "destroys the requested note" do
        note = Note.create! valid_attributes
        expect {
          delete card_note_url(card,note)
        }.to change(Note, :count).by(-1)
      end

      it "redirects to the notes list" do
        note = Note.create! valid_attributes
        delete card_note_url(card,note)
        skip "broadcasts refresh"
        expect(response).to redirect_to(notes_url)
      end
    end
  end
end
