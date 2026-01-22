require 'rails_helper'

RSpec.describe "CardCertificates", type: :request do
  let(:card_certificate) { FactoryBot.create(:card_certificate) }

  before(:each) do
    login_admin
  end

  describe "GET /index" do
    it "returns http success" do
      get card_certificates_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get card_certificate_path(card_certificate)
      expect(response).to have_http_status(:success)
    end
  end

end
