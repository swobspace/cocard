require 'rails_helper'

RSpec.describe "/logs", type: :request do
  let(:conn) { FactoryBot.create(:connector) }
  
  let(:valid_attributes) {
    FactoryBot.attributes_for(:log, loggable_type: 'Connector', loggable_id: conn.id)
  }

  let(:invalid_attributes) {{
    action: nil, level: nil
  }}

  before(:each) do
    login_admin
  end
 
  describe "GET /index" do
    it "renders a successful response" do
      puts valid_attributes.inspect
      puts conn.class.name
      Log.create! valid_attributes
      get logs_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      log = Log.create! valid_attributes
      get log_url(log)
      expect(response).to be_successful
    end
  end

#  describe "GET /new" do
#    it "renders a successful response" do
#      get new_log_url
#      expect(response).to be_successful
#    end
#  end
#
#  describe "GET /edit" do
#    it "renders a successful response" do
#      log = Log.create! valid_attributes
#      get edit_log_url(log)
#      expect(response).to be_successful
#    end
#  end
#
#  describe "POST /create" do
#    context "with valid parameters" do
#      it "creates a new Log" do
#        expect {
#          post logs_url, params: { log: valid_attributes }
#        }.to change(Log, :count).by(1)
#      end
#
#      it "redirects to the created log" do
#        post logs_url, params: { log: valid_attributes }
#        expect(response).to redirect_to(log_url(Log.last))
#      end
#    end
#
#    context "with invalid parameters" do
#      it "does not create a new Log" do
#        expect {
#          post logs_url, params: { log: invalid_attributes }
#        }.to change(Log, :count).by(0)
#      end
#
#    
#      it "renders a response with 422 status (i.e. to display the 'new' template)" do
#        post logs_url, params: { log: invalid_attributes }
#        expect(response).to have_http_status(:unprocessable_entity)
#      end
#    
#    end
#  end
#
#  describe "PATCH /update" do
#    context "with valid parameters" do
#      let(:new_attributes) {
#        skip("Add a hash of attributes valid for your model")
#      }
#
#      it "updates the requested log" do
#        log = Log.create! valid_attributes
#        patch log_url(log), params: { log: new_attributes }
#        log.reload
#        skip("Add assertions for updated state")
#      end
#
#      it "redirects to the log" do
#        log = Log.create! valid_attributes
#        patch log_url(log), params: { log: new_attributes }
#        log.reload
#        expect(response).to redirect_to(log_url(log))
#      end
#    end
#
#    context "with invalid parameters" do
#    
#      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
#        log = Log.create! valid_attributes
#        patch log_url(log), params: { log: invalid_attributes }
#        expect(response).to have_http_status(:unprocessable_entity)
#      end
#    
#    end
#  end

  describe "DELETE /destroy" do
    it "destroys the requested log" do
      log = Log.create! valid_attributes
      expect {
        delete log_url(log)
      }.to change(Log, :count).by(-1)
    end

    it "redirects to the logs list" do
      log = Log.create! valid_attributes
      delete log_url(log)
      expect(response).to redirect_to(logs_url)
    end
  end
end
