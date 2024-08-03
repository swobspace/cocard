require "rails_helper"

RSpec.describe CardsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/cards").to route_to("cards#index")
    end

    it "routes to #sindex" do
      expect(get: "/cards/sindex").to route_to("cards#sindex")
    end

    it "routes to #new" do
      expect(get: "/cards/new").to route_to("cards#new")
    end

    it "routes to #show" do
      expect(get: "/cards/1").to route_to("cards#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/cards/1/edit").to route_to("cards#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/cards").to route_to("cards#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/cards/1").to route_to("cards#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/cards/1").to route_to("cards#update", id: "1")
    end

    it "routes to #get_certificate via POST" do
      expect(post: "/cards/1/get_certificate").to route_to("cards#get_certificate", id: "1")
    end

    it "routes to #get_pin_status via POST" do
      expect(post: "/cards/1/get_pin_status").to route_to("cards#get_pin_status", id: "1")
    end

    it "routes to #verify_pin via POST" do
      expect(post: "/cards/1/verify_pin").to route_to("cards#verify_pin", id: "1")
    end

    it "routes to #get_card via POST" do
      expect(post: "/cards/1/get_card").to route_to("cards#get_card", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/cards/1").to route_to("cards#destroy", id: "1")
    end
  end
end
