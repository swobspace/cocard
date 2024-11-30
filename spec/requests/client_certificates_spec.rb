require 'rails_helper'

RSpec.describe "/client_certificates", type: :request do
  let(:p12) do
    Rack::Test::UploadedFile.new(
      Rails.root.join('spec', 'fixtures', 'files', 'demo.p12')
    )
  end
  let(:p12_pass) { 'justfortesting' }

  let(:valid_attributes) {
    FactoryBot.attributes_for(:client_certificate,
      cert: File.read(File.join(Rails.root, 'spec/fixtures/files', 'demo-cert.pem')),
      pkey: File.read(File.join(Rails.root, 'spec/fixtures/files', 'demo-pkey.pem')),
      passphrase: 'justfortesting'
    )
  }

  let(:invalid_attributes) {
    { cert: nil, pkey: nil, name: nil }
  }

  before(:each) do
    login_admin
  end

  describe "GET /index" do
    it "renders a successful response" do
      ClientCertificate.create! valid_attributes
      get client_certificates_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      client_certificate = ClientCertificate.create! valid_attributes
      get client_certificate_url(client_certificate)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_client_certificate_url
      expect(response).to be_successful
    end
  end

  describe "GET /import_p12" do
    it "renders a successful response" do
      get new_client_certificate_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      client_certificate = ClientCertificate.create! valid_attributes
      get edit_client_certificate_url(client_certificate)
      expect(response).to be_successful
    end
  end

  describe "with plaintext cert/key" do
    describe "POST /create" do
      context "with valid parameters" do
        it "creates a new ClientCertificate" do
          expect {
            post client_certificates_url, params: { client_certificate: valid_attributes }
          }.to change(ClientCertificate, :count).by(1)
        end

        it "redirects to the created client_certificate" do
          post client_certificates_url, params: { client_certificate: valid_attributes }
          expect(response).to redirect_to(client_certificate_url(ClientCertificate.last))
        end
      end

      context "with invalid parameters" do
        it "does not create a new ClientCertificate" do
          expect {
            post client_certificates_url, params: { client_certificate: invalid_attributes }
          }.to change(ClientCertificate, :count).by(0)
        end

      
        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          post client_certificates_url, params: { client_certificate: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      
      end
    end
  end

  describe "with p12 file" do
    let(:valid_attributes) do
      { 
        name: 'P12-Demo',
        description: 'just a test for p12',
        p12: p12,
        passphrase: p12_pass
      }
    end

    describe "POST /create" do
      context "with valid parameters" do
        it "creates a new ClientCertificate" do
          expect {
            post client_certificates_url, params: { client_certificate: valid_attributes }
          }.to change(ClientCertificate, :count).by(1)
        end

        it "redirects to the created client_certificate" do
          post client_certificates_url, params: { client_certificate: valid_attributes }
          expect(response).to redirect_to(client_certificate_url(ClientCertificate.last))
        end
      end

      context "with invalid parameters" do
        it "does not create a new ClientCertificate" do
          expect {
            post client_certificates_url, params: { client_certificate: invalid_attributes }
          }.to change(ClientCertificate, :count).by(0)
        end

      
        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          post client_certificates_url, params: { client_certificate: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      
      end
    end
  end

  describe "with wrong p12 file" do
    let(:p12) do
      Rack::Test::UploadedFile.new(
        Rails.root.join('spec', 'fixtures', 'files', 'connector.sds')
      )
    end
    let(:valid_attributes) do
      { 
        name: 'P12-Demo',
        description: 'just a test for p12',
        p12: p12,
        passphrase: p12_pass
      }
    end

    describe "POST /create" do
      context "with valid parameters" do
        it "creates a new ClientCertificate" do
          expect {
            post client_certificates_url, params: { client_certificate: valid_attributes }
          }.to change(ClientCertificate, :count).by(0)
        end

        it "renders a response with 422 status" do
          post client_certificates_url, params: { client_certificate: valid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "redirects to the created client_certificate" do
          post client_certificates_url, params: { client_certificate: valid_attributes }
          expect(response.body).to match(/Client-Zertifikat importieren/)
        end
      end

      context "with invalid parameters" do
        it "does not create a new ClientCertificate" do
          expect {
            post client_certificates_url, params: { client_certificate: invalid_attributes }
          }.to change(ClientCertificate, :count).by(0)
        end

      
        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          post client_certificates_url, params: { client_certificate: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {{
        name: "newname",
        description: "more information"
      }}

      it "updates the requested client_certificate" do
        client_certificate = ClientCertificate.create! valid_attributes
        patch client_certificate_url(client_certificate), params: { client_certificate: new_attributes }
        client_certificate.reload
        expect(client_certificate.name).to eq("newname")
        expect(client_certificate.description.to_plain_text).to eq("more information")
      end

      it "redirects to the client_certificate" do
        client_certificate = ClientCertificate.create! valid_attributes
        patch client_certificate_url(client_certificate), params: { client_certificate: new_attributes }
        client_certificate.reload
        expect(response).to redirect_to(client_certificate_url(client_certificate))
      end
    end

    context "with invalid parameters" do
    
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        client_certificate = ClientCertificate.create! valid_attributes
        patch client_certificate_url(client_certificate), params: { client_certificate: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested client_certificate" do
      client_certificate = ClientCertificate.create! valid_attributes
      expect {
        delete client_certificate_url(client_certificate)
      }.to change(ClientCertificate, :count).by(-1)
    end

    it "redirects to the client_certificates list" do
      client_certificate = ClientCertificate.create! valid_attributes
      delete client_certificate_url(client_certificate)
      expect(response).to redirect_to(client_certificates_url)
    end
  end
end
