require 'rails_helper'

RSpec.describe "CardCertificates", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/card_certificates/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/card_certificates/show"
      expect(response).to have_http_status(:success)
    end
  end

end
