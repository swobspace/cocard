require 'rails_helper'

RSpec.describe "IdleMessages", type: :request do
  let(:connector) { FactoryBot.create(:connector) }
  let!(:ct) do 
    FactoryBot.create(:card_terminal, :with_mac,
      connector: connector
    )
  end

  before(:each) do
    login_admin
    allow(ct).to receive(:supports_rmi?).and_return(true)
    ct.update_column(:condition, Cocard::States::OK)
    ct.reload
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
      idle_message: "some information text"
    }}

    it "returns http success" do
      expect(CardTerminals::RMI::SetIdleMessageJob).to receive_message_chain(:set, :perform_later).with(card_terminal: [ct], idle_message: new_attributes[:idle_message])
      put idle_messages_url, params: new_attributes
      expect(response).to redirect_to(idle_messages_url)
    end
  end

end
