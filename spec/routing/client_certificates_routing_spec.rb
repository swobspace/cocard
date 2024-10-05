require "rails_helper"

RSpec.describe ClientCertificatesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/client_certificates").to route_to("client_certificates#index")
    end

    it "routes to #new" do
      expect(get: "/client_certificates/new").to route_to("client_certificates#new")
    end

    it "routes to #show" do
      expect(get: "/client_certificates/1").to route_to("client_certificates#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/client_certificates/1/edit").to route_to("client_certificates#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/client_certificates").to route_to("client_certificates#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/client_certificates/1").to route_to("client_certificates#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/client_certificates/1").to route_to("client_certificates#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/client_certificates/1").to route_to("client_certificates#destroy", id: "1")
    end

    it "routes to #import_p12_form" do
      expect(get: "/client_certificates/import_p12_form").to route_to("client_certificates#import_p12_form")
    end

    it "routes to #import_p12" do
      expect(post: "/client_certificates/import_p12").to route_to("client_certificates#import_p12")
    end

  end
end
