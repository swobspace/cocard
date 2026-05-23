require "rails_helper"

RSpec.describe OidsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/oids").to route_to("oids#index")
    end

    it "routes to #new" do
      expect(get: "/oids/new").to route_to("oids#new")
    end

    it "routes to #show" do
      expect(get: "/oids/1").to route_to("oids#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/oids/1/edit").to route_to("oids#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/oids").to route_to("oids#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/oids/1").to route_to("oids#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/oids/1").to route_to("oids#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/oids/1").to route_to("oids#destroy", id: "1")
    end
  end
end
