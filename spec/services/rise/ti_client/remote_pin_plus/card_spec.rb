# frozen_string_literal: true

require 'rails_helper'
module RISE
  RSpec.describe TIClient::RemotePinPlus::Card do
    let(:configuration) {{
      "card" => {
        "iccsn"=>"80276001731001234567",
        "cardHolder"=>"Irgend eine Einrichtung",
        "terminalId"=>"00:0D:F8:07:2C:B0",
        "terminalHostname"=>"ORGA6100-01400123456789",
        "cardType"=>"SMCB"
      },
      "status" => "ACTIVE"
    }}

    subject { RISE::TIClient::RemotePinPlus::Card.new(configuration) }

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(RISE::TIClient::RemotePinPlus::Card) }
      it { expect(subject.respond_to?(:iccsn)).to be_truthy }
      it { expect(subject.respond_to?(:card_holder)).to be_truthy }
      it { expect(subject.respond_to?(:terminal_id)).to be_truthy }
      it { expect(subject.respond_to?(:terminal_name)).to be_truthy }
      it { expect(subject.respond_to?(:card_type)).to be_truthy }
      it { expect(subject.respond_to?(:state)).to be_truthy }
    end

    describe '::new' do
      context 'without argument' do
        it 'raises a KeyError' do
          expect do
            RISE::TIClient::RemotePinPlus::Card.new()
          end.to raise_error(ArgumentError)
        end
      end

      context "with data" do
        it { expect(subject.iccsn).to eq("80276001731001234567") }
        it { expect(subject.card_holder).to eq("Irgend eine Einrichtung") }
        it { expect(subject.terminal_id).to eq("00:0D:F8:07:2C:B0") }
        it { expect(subject.terminal_name).to eq("ORGA6100-01400123456789") }
        it { expect(subject.card_type).to eq("SMCB") }
        it { expect(subject.state).to eq("ACTIVE") }
      end
    end
  end
end

