# frozen_string_literal: true

require 'rails_helper'
module CardTerminals::RMI
  RSpec.describe OrgaV1 do
    let(:ct) do
      FactoryBot.create(:card_terminal,
        mac: ENV['CT_MAC'],
        ip: ENV['CT_IP']
      )
    end
    let(:card) do
      FactoryBot.create(:card,
        iccsn: ENV['CARD_ICCSN'],
      )
    end
  
    subject { CardTerminals::RMI::OrgaV1.new(card_terminal: ct, iccsn: card.iccsn) }

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(CardTerminals::RMI::OrgaV1) }
      it { expect(subject.respond_to?(:valid)).to be_truthy }
    end

    describe '::new' do
      context 'without :card_terminal' do
        it 'raises a KeyError' do
          expect do
            OrgaV1.new()
          end.to raise_error(KeyError)
        end
      end
    end

    describe 'without valid product information' do
      it { expect(subject.valid).to be_falsey }
      it { expect(subject.session).to be_empty }
    end

    describe 'with valid product information' do
      before(:each) do
        allow(ct).to receive(:firmware_version).and_return('3.9.0')
        allow(ct).to receive_message_chain(:product_information, :product_code).and_return('ORGA6100')
        ct.update(pin_mode: 'on_demand')
        ct.reload
      end
      it { expect(subject.valid).to be_truthy }

      describe "#verify_pin", :rmi => true do
        it { subject.verify_pin }
      end
    end

  end
end
