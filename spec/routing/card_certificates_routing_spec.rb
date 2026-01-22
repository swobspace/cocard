require "rails_helper"

RSpec.describe CardCertificatesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/card_certificates").to route_to("card_certificates#index")
    end

    it "routes to #show" do
      expect(get: "/card_certificates/1").to route_to("card_certificates#show", id: "1")
    end

  end
end
