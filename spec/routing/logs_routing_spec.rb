require "rails_helper"

RSpec.describe LogsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/logs").to route_to("logs#index")
    end

    it "routes to #sindex" do
      expect(get: "/logs/sindex").to route_to("logs#sindex")
    end

    it "routes to #new" do
      skip "test does not work"
      # expect(get: "/logs/new").to route_to("logs#new")
      expect(get: "/logs/new").not_to be_routable
    end

    it "routes to #show" do
      expect(get: "/logs/1").to route_to("logs#show", id: "1")
    end

    it "routes to #edit" do
      # expect(get: "/logs/1/edit").to route_to("logs#edit", id: "1")
      expect(get: "/logs/1/edit").not_to be_routable
    end

    it "routes to #delete_outdated" do
      expect(delete: "/logs/delete_outdated").to route_to("logs#delete_outdated")
    end

    it "routes to #invalidate_outdated" do
      expect(put: "/logs/invalidate_outdated").to route_to("logs#invalidate_outdated")
    end

    it "routes to #create" do
      # expect(post: "/logs").to route_to("logs#create")
      expect(post: "/logs").not_to be_routable
    end

    it "routes to #update via PUT" do
      expect(put: "/logs/1").to route_to("logs#update", id: "1")
      # expect(put: "/logs/1").not_to be_routable
    end

    it "routes to #update via PATCH" do
      expect(patch: "/logs/1").to route_to("logs#update", id: "1")
      # expect(patch: "/logs/1").not_to be_routable
    end

    it "routes to #destroy" do
      expect(delete: "/logs/1").to route_to("logs#destroy", id: "1")
    end
  end
end
