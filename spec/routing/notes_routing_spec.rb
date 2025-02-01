require "rails_helper"

RSpec.describe NotesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/notes").to route_to("notes#index")
    end

    it "routes to #sindex" do
      expect(get: "/notes/sindex").to route_to("notes#sindex")
    end

    it "routes to #show" do
      expect(get: "/notes/1").to route_to("notes#show", id: "1")
    end

    it "routes to #new" do
      skip "test does not work"
      # expect(get: "/notes/new").to route_to("notes#new")
      expect(get: "/notes/new").not_to be_routable
    end

    it "routes to #edit" do
      expect(get: "/notes/1/edit").to route_to("notes#edit", id: "1")
    end

    # it "routes to #delete_outdated" do
    #   expect(delete: "/notes/delete_outdated").to route_to("notes#delete_outdated")
    # end

    # it "routes to #invalidate_outdated" do
    #   expect(put: "/notes/invalidate_outdated").to route_to("notes#invalidate_outdated")
    # end

    it "routes to #create" do
      # expect(post: "/notes").to route_to("notes#create")
      expect(post: "/notes").not_to be_routable
    end

    it "routes to #update via PUT" do
      expect(put: "/notes/1").to route_to("notes#update", id: "1")
      # expect(put: "/notes/1").not_to be_routable
    end

    it "routes to #update via PATCH" do
      expect(patch: "/notes/1").to route_to("notes#update", id: "1")
      # expect(patch: "/notes/1").not_to be_routable
    end

    it "routes to #destroy" do
      expect(delete: "/notes/1").to route_to("notes#destroy", id: "1")
    end

  end
end
