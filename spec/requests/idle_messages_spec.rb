require 'rails_helper'

RSpec.describe "IdleMessages", type: :request do

  before(:each) do
    login_admin
  end

  describe "GET /index" do
    it "returns http success" do
      get idle_messages_url
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get idle_messages_edit_url
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT /update" do
    let(:new_attributes) {{
      message: "some information text"
    }}

    it "returns http success" do
      put idle_messages_url, params: new_attributes
      expect(Card::Terminals::RMI::SetIdleMessageJob).to receive(:perform_later).with(:any_args)
      expect(response).to have_http_status(:success)
    end
  end

end
