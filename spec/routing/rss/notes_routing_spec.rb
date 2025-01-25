require "rails_helper"

RSpec.describe Rss::NotesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/rss/notes.xml").to route_to(controller: "rss/notes", 
                                                action: "index", format: 'xml')
    end
  end
end
