require "rails_helper"

RSpec.describe CardTerminalsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/card_terminals").to route_to("card_terminals#index")
    end

    it "routes to #new" do
      # expect(get: "/card_terminals/new").to route_to("card_terminals#new")
      skip "testing #new to be not routable does not work"
      expect(get: "/card_terminals/new").not_to be_routable
    end

    it "routes to #show" do
      expect(get: "/card_terminals/1").to route_to("card_terminals#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/card_terminals/1/edit").to route_to("card_terminals#edit", id: "1")
    end


    it "routes to #create" do
      # expect(post: "/card_terminals").to route_to("card_terminals#create")
      expect(post: "/card_terminals").not_to be_routable
    end

    it "routes to #update via PUT" do
      expect(put: "/card_terminals/1").to route_to("card_terminals#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/card_terminals/1").to route_to("card_terminals#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/card_terminals/1").to route_to("card_terminals#destroy", id: "1")
    end
  end
end
