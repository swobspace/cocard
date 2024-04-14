require "rails_helper"

RSpec.describe ConnectorsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/connectors").to route_to("connectors#index")
    end

    it "routes to #new" do
      expect(get: "/connectors/new").to route_to("connectors#new")
    end

    it "routes to #show" do
      expect(get: "/connectors/1").to route_to("connectors#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/connectors/1/edit").to route_to("connectors#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/connectors").to route_to("connectors#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/connectors/1").to route_to("connectors#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/connectors/1").to route_to("connectors#update", id: "1")
    end

    it "routes to #fetch_sds via POST" do
      expect(post: "/connectors/1/fetch_sds").to route_to("connectors#fetch_sds", id: "1")
    end


    it "routes to #destroy" do
      expect(delete: "/connectors/1").to route_to("connectors#destroy", id: "1")
    end
  end
end
