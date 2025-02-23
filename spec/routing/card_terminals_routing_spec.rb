require "rails_helper"

RSpec.describe CardTerminalsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/card_terminals").to route_to("card_terminals#index")
    end

    it "routes to #sindex" do
      expect(get: "/card_terminals/sindex").to route_to("card_terminals#sindex")
    end

    it "routes to #new" do
      expect(get: "/card_terminals/new").to route_to("card_terminals#new")
    end

    it "routes to #show" do
      expect(get: "/card_terminals/1").to route_to("card_terminals#show", id: "1")
    end

    it "routes to #ping" do
      expect(get: "/card_terminals/1/ping").to route_to("card_terminals#ping", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/card_terminals/1/edit").to route_to("card_terminals#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/card_terminals").to route_to("card_terminals#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/card_terminals/1").to route_to("card_terminals#update", id: "1")
    end

    it "routes to #fetch_idle_message via PUT" do
      expect(post: "/card_terminals/1/fetch_idle_message").to route_to("card_terminals#fetch_idle_message", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/card_terminals/1").to route_to("card_terminals#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/card_terminals/1").to route_to("card_terminals#destroy", id: "1")
    end
  end
end
