# frozen_string_literal: true

require "rails_helper"

RSpec.describe Card::ContextAuthenticationComponent, type: :component do
  let(:card) { FactoryBot.create(:card) }
  let(:context) { FactoryBot.create(:context, client_system: 'MyClient') }

  describe "without connector " do
    it "don't render anything" do
      render_inline(described_class.new(card: card, context: context))
      expect(page).not_to have_content("Authentifizierung")
    end
  end

  describe "with connector" do
    let(:conn) { FactoryBot.create(:connector) }
    before(:each) do
      allow(card).to receive_message_chain(:card_terminal, :connector).and_return(conn)
    end

    it "with can_authenticate? == true" do
      expect(conn).to receive(:can_authenticate?).with(any_args).and_return(true)
      render_inline(described_class.new(card: card, context: context))
      expect(page).to have_content("Authentifizierung ok")
    end

    it "with can_authenticate? == false" do
      expect(conn).to receive(:can_authenticate?).with(any_args).and_return(false)
      render_inline(described_class.new(card: card, context: context))
      expect(page).to have_content("Authentifizierung nicht möglich")
    end
  end
  
end
