require "rails_helper"

RSpec.describe CardsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/cards").to route_to("cards#index")
    end

    it "routes to #new" do
      skip "testing #new to be not routable does not work"
      # expect(get: "/cards/new").to route_to("cards#new")
      expect(get: "/cards/new").not_to be_routable
    end

    it "routes to #show" do
      expect(get: "/cards/1").to route_to("cards#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/cards/1/edit").to route_to("cards#edit", id: "1")
    end


    it "routes to #create" do
      # expect(post: "/cards").to route_to("cards#create")
      expect(post: "/cards").not_to be_routable
    end

    it "routes to #update via PUT" do
      expect(put: "/cards/1").to route_to("cards#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/cards/1").to route_to("cards#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/cards/1").to route_to("cards#destroy", id: "1")
    end
  end
end
