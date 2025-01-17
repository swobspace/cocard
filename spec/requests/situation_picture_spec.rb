require 'rails_helper'

RSpec.describe "SituationPictures", type: :request do
  before(:each) do
    login_admin
  end

  let(:valid_attributes) {  
    FactoryBot.attributes_for(:single_picture)
  }

  let(:invalid_attributes) {{
    ci: nil
  }}

  describe "GET /situation_picture" do
    it "returns http success" do
      get "/situation_picture"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /situation_picture/failed" do
    it "returns http success" do
      get "/situation_picture/failed"
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {{
        muted: true
      }}

      it "updates the requested single_picture" do
        single_picture = SinglePicture.create! valid_attributes
        expect(single_picture.muted).to be_falsey
        patch single_picture_url(single_picture), params: { single_picture: new_attributes }
        single_picture.reload
        expect(single_picture.muted).to be_truthy
      end

      it "redirects to the single_picture" do
        single_picture = SinglePicture.create! valid_attributes
        patch single_picture_url(single_picture), params: { single_picture: new_attributes }
        single_picture.reload
        expect(response).to redirect_to(single_picture_url(single_picture))
      end
    end

    context "with invalid parameters" do

      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        single_picture = SinglePicture.create! valid_attributes
        patch single_picture_url(single_picture), params: { single_picture: invalid_attributes }
        expect(response).to have_http_status(:see_other)
      end

    end
  end



end
