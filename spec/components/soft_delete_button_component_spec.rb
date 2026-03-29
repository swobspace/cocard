# frozen_string_literal: true

require "rails_helper"

RSpec.describe SoftDeleteButtonComponent, type: :component do
let(:conn) { FactoryBot.create(:connector) }

  it { expect(conn.respond_to?(:deleted_at)).to be_truthy }

  describe "soft deleted connector" do
    it "shows undelete button" do
      expect(conn).to receive(:deleted_at).and_return(Time.current)
      render_inline(described_class.new(poly: conn))
      expect(page).to have_css('button[class="btn btn-warning"]')
    end
  end

  describe "undeleted connector" do
    it "shows soft delete button" do
      expect(conn).to receive(:deleted_at).and_return(nil)
      render_inline(described_class.new(poly: conn))
      expect(page).to have_css('button[class="btn btn-danger me-1"]')
    end
  end


end
