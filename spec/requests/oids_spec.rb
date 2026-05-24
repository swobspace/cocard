require 'rails_helper'
RSpec.describe "/oids", type: :request do
  
  let(:valid_attributes) {
    FactoryBot.attributes_for(:oid)
  }

  let(:invalid_attributes) {
    { name: nil }
  }

  before(:each) do
    login_admin
  end

  describe "GET /index" do
    it "renders a successful response" do
      Oid.create! valid_attributes
      get oids_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      oid = Oid.create! valid_attributes
      get oid_url(oid)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_oid_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      oid = Oid.create! valid_attributes
      get edit_oid_url(oid)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Oid" do
        expect {
          post oids_url, params: { oid: valid_attributes }
        }.to change(Oid, :count).by(1)
      end

      it "redirects to the created oid" do
        post oids_url, params: { oid: valid_attributes }
        expect(response).to redirect_to(oid_url(Oid.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Oid" do
        expect {
          post oids_url, params: { oid: invalid_attributes }
        }.to change(Oid, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post oids_url, params: { oid: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { reference: "refbla", name: "NewName" }
      }

      it "updates the requested oid" do
        oid = Oid.create! valid_attributes
        patch oid_url(oid), params: { oid: new_attributes }
        oid.reload
        expect(oid.reference).to eq("refbla")
        expect(oid.name).to eq("NewName")
      end

      it "redirects to the oid" do
        oid = Oid.create! valid_attributes
        patch oid_url(oid), params: { oid: new_attributes }
        oid.reload
        expect(response).to redirect_to(oid_url(oid))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        oid = Oid.create! valid_attributes
        patch oid_url(oid), params: { oid: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested oid" do
      oid = Oid.create! valid_attributes
      expect {
        delete oid_url(oid)
      }.to change(Oid, :count).by(-1)
    end

    it "redirects to the oids list" do
      oid = Oid.create! valid_attributes
      delete oid_url(oid)
      expect(response).to redirect_to(oids_url)
    end
  end
end
