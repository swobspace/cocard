require "rails_helper"

RSpec.describe TIClientsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/ti_clients").to route_to("ti_clients#index")
    end

    it "routes to #new" do
      expect(get: "/ti_clients/new").to route_to("ti_clients#new")
    end

    it "routes to #show" do
      expect(get: "/ti_clients/1").to route_to("ti_clients#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/ti_clients/1/edit").to route_to("ti_clients#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/ti_clients").to route_to("ti_clients#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/ti_clients/1").to route_to("ti_clients#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/ti_clients/1").to route_to("ti_clients#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/ti_clients/1").to route_to("ti_clients#destroy", id: "1")
    end
  end
end
