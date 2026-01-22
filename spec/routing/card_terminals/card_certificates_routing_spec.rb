require "rails_helper"

RSpec.describe CardTerminals::CardCertificatesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/card_terminals/88/card_certificates").to route_to("card_terminals/card_certificates#index", card_terminal_id: '88')
    end

    it "routes to #show" do
      expect(get: "/card_terminals/88/card_certificates/1").to route_to("card_terminals/card_certificates#show", id: "1", card_terminal_id: '88')
    end

    it "routes to #fetch via POST" do
      expect(post: "/card_terminals/88/card_certificates/fetch").to route_to("card_terminals/card_certificates#fetch", card_terminal_id: '88')
    end
  end

end
