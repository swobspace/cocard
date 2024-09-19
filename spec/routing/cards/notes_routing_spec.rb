require "rails_helper"

RSpec.describe Cards::NotesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/cards/88/notes").to route_to("cards/notes#index", card_id: '88')
    end

    it "routes to #new" do
      expect(get: "/cards/88/notes/new").to route_to("cards/notes#new", card_id: '88')
    end

    it "routes to #show" do
      expect(get: "/cards/88/notes/1").to route_to("cards/notes#show", id: "1", card_id: '88')
    end

    it "routes to #edit" do
      expect(get: "/cards/88/notes/1/edit").to route_to("cards/notes#edit", id: "1", card_id: '88')
    end


    it "routes to #create" do
      expect(post: "/cards/88/notes").to route_to("cards/notes#create", card_id: '88')
    end

    it "routes to #update via PUT" do
      expect(put: "/cards/88/notes/1").to route_to("cards/notes#update", id: "1", card_id: '88')
    end

    it "routes to #update via PATCH" do
      expect(patch: "/cards/88/notes/1").to route_to("cards/notes#update", id: "1", card_id: '88')
    end

    it "routes to #destroy" do
      expect(delete: "/cards/88/notes/1").to route_to("cards/notes#destroy", id: "1", card_id: '88')
    end
  end
end
