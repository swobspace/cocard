require "rails_helper"

RSpec.describe CardTerminals::CardTerminalSlotsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/card_terminals/88/card_terminal_slots").to route_to("card_terminals/card_terminal_slots#index", card_terminal_id: "88")
    end

    it "routes to #new" do
      expect(get: "/card_terminals/88/card_terminal_slots/new").to route_to("card_terminals/card_terminal_slots#new", card_terminal_id: "88")
    end

    it "routes to #show" do
      expect(get: "/card_terminals/88/card_terminal_slots/1").to route_to("card_terminals/card_terminal_slots#show", id: "1", card_terminal_id: "88")
    end

    it "routes to #edit" do
      expect(get: "/card_terminals/88/card_terminal_slots/1/edit").to route_to("card_terminals/card_terminal_slots#edit", id: "1", card_terminal_id: "88")
    end


    it "routes to #create" do
      expect(post: "/card_terminals/88/card_terminal_slots").to route_to("card_terminals/card_terminal_slots#create", card_terminal_id: "88")
    end

    it "routes to #update via PUT" do
      expect(put: "/card_terminals/88/card_terminal_slots/1").to route_to("card_terminals/card_terminal_slots#update", id: "1", card_terminal_id: "88")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/card_terminals/88/card_terminal_slots/1").to route_to("card_terminals/card_terminal_slots#update", id: "1", card_terminal_id: "88")
    end

    it "routes to #destroy" do
      expect(delete: "/card_terminals/88/card_terminal_slots/1").to route_to("card_terminals/card_terminal_slots#destroy", id: "1", card_terminal_id: "88")
    end
  end
end
