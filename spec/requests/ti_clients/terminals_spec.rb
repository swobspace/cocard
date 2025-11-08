require 'rails_helper'

RSpec.describe "TIClients::Terminals", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/ti_clients/terminals/index"
      expect(response).to have_http_status(:success)
    end
  end

end
