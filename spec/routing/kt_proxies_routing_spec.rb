require "rails_helper"

RSpec.describe KTProxiesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/kt_proxies").to route_to("kt_proxies#index")
    end

    it "routes to #new" do
      expect(get: "/kt_proxies/new").to route_to("kt_proxies#new")
    end

    it "routes to #show" do
      expect(get: "/kt_proxies/1").to route_to("kt_proxies#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/kt_proxies/1/edit").to route_to("kt_proxies#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/kt_proxies").to route_to("kt_proxies#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/kt_proxies/1").to route_to("kt_proxies#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/kt_proxies/1").to route_to("kt_proxies#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/kt_proxies/1").to route_to("kt_proxies#destroy", id: "1")
    end
  end
end
