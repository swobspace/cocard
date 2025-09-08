require 'rails_helper'

RSpec.describe "/kt_proxies", type: :request do
  
  # This should return the minimal set of attributes required to create a valid
  # KTProxy. As you add validations to KTProxy, be sure to
  # adjust the attributes here as well.
  let(:tic) { FactoryBot.create(:ti_client) }
  let(:valid_attributes) {
    FactoryBot.attributes_for(:kt_proxy, ti_client_id: tic.id )
  }

  let(:invalid_attributes) {
    { card_terminal_ip: nil }
  }

  before(:each) do
    login_admin
  end

  describe "GET /index" do
    it "renders a successful response" do
      KTProxy.create! valid_attributes
      get kt_proxies_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      kt_proxy = KTProxy.create! valid_attributes
      get kt_proxy_url(kt_proxy)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_kt_proxy_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      kt_proxy = KTProxy.create! valid_attributes
      get edit_kt_proxy_url(kt_proxy)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new KTProxy" do
        expect {
          post kt_proxies_url, params: { kt_proxy: valid_attributes }
        }.to change(KTProxy, :count).by(1)
      end

      it "redirects to the created kt_proxy" do
        post kt_proxies_url, params: { kt_proxy: valid_attributes }
        expect(response).to redirect_to(kt_proxy_url(KTProxy.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new KTProxy" do
        expect {
          post kt_proxies_url, params: { kt_proxy: invalid_attributes }
        }.to change(KTProxy, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post kt_proxies_url, params: { kt_proxy: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {{
        name: "my buddy kt",
        card_terminal_port: 1234,
      }}

      it "updates the requested kt_proxy" do
        kt_proxy = KTProxy.create! valid_attributes
        patch kt_proxy_url(kt_proxy), params: { kt_proxy: new_attributes }
        kt_proxy.reload
        expect(kt_proxy.name).to eq("my buddy kt")
        expect(kt_proxy.card_terminal_port).to eq(1234)
      end

      it "redirects to the kt_proxy" do
        kt_proxy = KTProxy.create! valid_attributes
        patch kt_proxy_url(kt_proxy), params: { kt_proxy: new_attributes }
        kt_proxy.reload
        expect(response).to redirect_to(kt_proxy_url(kt_proxy))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        kt_proxy = KTProxy.create! valid_attributes
        patch kt_proxy_url(kt_proxy), params: { kt_proxy: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested kt_proxy" do
      kt_proxy = KTProxy.create! valid_attributes
      expect {
        delete kt_proxy_url(kt_proxy)
      }.to change(KTProxy, :count).by(-1)
    end

    it "redirects to the kt_proxies list" do
      kt_proxy = KTProxy.create! valid_attributes
      delete kt_proxy_url(kt_proxy)
      expect(response).to redirect_to(kt_proxies_url)
    end
  end
end
