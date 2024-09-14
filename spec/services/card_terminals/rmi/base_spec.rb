# frozen_string_literal: true

require 'rails_helper'
module CardTerminals::RMI
  RSpec.describe Base do
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
  
    subject { CardTerminals::RMI::Base.new(card_terminal: ct) }

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(CardTerminals::RMI::Base) }
      it { expect(subject.respond_to?(:valid)).to be_truthy }
    end

    describe '::new' do
      context 'without :card_terminal' do
        it 'raises a KeyError' do
          expect do
            Base.new()
          end.to raise_error(KeyError)
        end
      end
    end

    describe 'without valid product information' do
      it { expect(subject.valid).to be_falsey }
      it { expect(subject.rmi).to be_nil }
    end

    describe 'with valid product information' do
      before(:each) do
        allow(ct).to receive(:firmware_version).and_return('3.9.0')
        allow(ct).to receive_message_chain(:product_information, :product_code).and_return('ORGA6100')
      end
      it { expect(subject.valid).to be_truthy }

      describe "#rmi" do
        it { expect(subject.rmi).to eq(CardTerminals::RMI::OrgaV1) }
      end
    end

  end
end
