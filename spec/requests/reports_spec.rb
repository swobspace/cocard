require 'rails_helper'

RSpec.describe "Reports", type: :request do
  describe "GET /duplicate_terminal_ips" do
    it "returns http success" do
      get "/reports/duplicate_terminal_ips"
      expect(response).to have_http_status(:success)
    end
  end

end
