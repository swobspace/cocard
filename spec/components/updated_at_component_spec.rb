# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdatedAtComponent, type: :component do
  let(:card) { FactoryBot.create(:card) }

  describe "with updated_at is current" do
    it "shows green ok utf char" do
      expect(card).to receive(:updated_at).and_return(Time.current)
      render_inline(described_class.new(item: card))
      expect(page).to have_content(Cocard::States.flag(Cocard::States::OK))
    end
  end

  describe "with updated_at to old" do
    it "shows yellow warning utf char" do
      expect(card).to receive(:updated_at).at_least(:once).and_return(1.day.before(Time.current))
      render_inline(described_class.new(item: card))
      expect(page).to have_content(Cocard::States.flag(Cocard::States::WARNING))
    end
  end

end
