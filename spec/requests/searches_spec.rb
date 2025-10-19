require 'rails_helper'

RSpec.describe "Searches", type: :request do
  before(:each) do
    login_admin
  end

  describe "GET /search with search params" do
    it "query tag returns http success" do
      get search_url(query: 'tag:MyTag K03')
      expect(response).to have_http_status(:success)
    end

    it "query ip returns http success" do
      get search_url(query: 'ip:1.2.3.4')
      expect(response).to have_http_status(:success)
    end

    it "search for 014000000179E0 returns http success" do
      get search_url(query: '014000000179E0')
      expect(response).to have_http_status(:success)
    end

    it "search for 000DF8072C9A returns http success" do
      get search_url(query: '000DF8072C9A')
      expect(response).to have_http_status(:success)
    end
  end

end
