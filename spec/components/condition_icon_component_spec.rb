# frozen_string_literal: true

require "rails_helper"

RSpec.describe ConditionIconComponent, type: :component do
  describe "with connector" do
    let(:connector) { FactoryBot.create(:connector) }

    describe "with condition = CRITICAL" do
      it "shows CRITICAL button" do
        expect(connector).to receive(:condition).at_least(:once)
                                                .and_return(Cocard::States::CRITICAL)
        render_inline(described_class.new(item: connector))
        expect(page).to have_css('button[class="position-relative btn btn-danger"]')
      end
    end

    describe "with condition = WARNING" do
      it "shows WARNING button" do
        expect(connector).to receive(:condition).at_least(:once)
                                                .and_return(Cocard::States::WARNING)
        render_inline(described_class.new(item: connector))
        expect(page).to have_css('button[class="position-relative btn btn-warning"]')
      end
    end

    describe "with condition = OK, certificate valid" do
      it "shows OK button" do
        expect(connector).to receive(:condition).at_least(:once)
                                                .and_return(Cocard::States::OK)
        render_inline(described_class.new(item: connector))
        expect(page).to have_css('button[class="position-relative btn btn-success"]')
      end
    end

    describe "with condition = OK, certificate expiring soon" do
      it "shows OK button and cert button" do
        expect(connector).to receive(:condition).at_least(:once)
                                                .and_return(Cocard::States::OK)
        expect(connector).to receive(:expiration_date).at_least(:once)
                                                .and_return(1.month.after(Date.current))
        render_inline(described_class.new(item: connector))
        expect(page).to have_css('button[class="position-relative btn btn-success"]')
        expect(page).to have_css('span[class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-warning"]')
      end
    end

    describe "with condition = UNKNOWN" do
      it "shows UNKNOWN button" do
        expect(connector).to receive(:condition).at_least(:once)
                                                .and_return(Cocard::States::UNKNOWN)
        render_inline(described_class.new(item: connector))
        expect(page).to have_css('button[class="position-relative btn btn-info"]')
      end
    end

    describe "with deleted connector" do
      it "shows trash button" do
        expect(connector).to receive(:deleted_at).at_least(:once)
                                                .and_return(1.minute.before(Time.current))
        render_inline(described_class.new(item: connector))
        expect(page).to have_css('button[class="position-relative btn btn-secondary"]')
      end
    end

  end
end
