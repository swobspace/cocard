require 'rails_helper'

RSpec.describe "VerifyPins", type: :request do

  before(:each) do
    login_admin
  end

  describe "GET /index" do
    it "returns http success" do
      get "/verify_pins"
      expect(response).to have_http_status(:success)
    end
  end

end
