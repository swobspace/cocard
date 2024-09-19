require "rails_helper"

RSpec.describe CardTerminals::NotesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/card_terminals/88/notes").to route_to("card_terminals/notes#index", card_terminal_id: '88')
    end

    it "routes to #new" do
      expect(get: "/card_terminals/88/notes/new").to route_to("card_terminals/notes#new", card_terminal_id: '88')
    end

    it "routes to #show" do
      expect(get: "/card_terminals/88/notes/1").to route_to("card_terminals/notes#show", id: "1", card_terminal_id: '88')
    end

    it "routes to #edit" do
      expect(get: "/card_terminals/88/notes/1/edit").to route_to("card_terminals/notes#edit", id: "1", card_terminal_id: '88')
    end


    it "routes to #create" do
      expect(post: "/card_terminals/88/notes").to route_to("card_terminals/notes#create", card_terminal_id: '88')
    end

    it "routes to #update via PUT" do
      expect(put: "/card_terminals/88/notes/1").to route_to("card_terminals/notes#update", id: "1", card_terminal_id: '88')
    end

    it "routes to #update via PATCH" do
      expect(patch: "/card_terminals/88/notes/1").to route_to("card_terminals/notes#update", id: "1", card_terminal_id: '88')
    end

    it "routes to #destroy" do
      expect(delete: "/card_terminals/88/notes/1").to route_to("card_terminals/notes#destroy", id: "1", card_terminal_id: '88')
    end
  end
end
