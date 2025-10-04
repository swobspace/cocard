require 'rails_helper'

module Cocard
  RSpec.describe GetCard do
    # 
    #  create fake response for Cocard::Soap::GetCard
    #
    let(:connector_yml) do
      File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector_services.yaml')
    end

    let(:card_yml) do
      file = File.join(Rails.root, 'spec', 'fixtures', 'files', 
                       'get_card_per_iccsn_response.yml')
      File.read(file)
    end

    let(:fake_ok)  { Fake.new(true, [], 
                              YAML.unsafe_load(card_yml)) }
    let(:fake_err) { Fake.new(false, ['something is wrong'], nil) }

    let(:pin_ok) { Fake.new(true, nil, nil) }

    #
    # connector and context
    #
    let(:connector) do
      FactoryBot.create(:connector,
        ip: ENV['SDS_IP'],
        connector_services: YAML.load_file(connector_yml)
      )
    end

    let(:context) { FactoryBot.create(:context) }

    let!(:ct) do
       FactoryBot.create(:card_terminal, :with_mac,
         connector: connector,
         ct_id: 'CT_ID_0176'
       )
    end

    let(:mycard) do
      FactoryBot.create(:card,
        card_terminal: ct,
        iccsn: ENV['CARD_ICCSN']
      )
    end

    before(:each) do
      mycard.contexts << context
    end

    subject do
      Cocard::GetCard.new(card: mycard, context: context)
    end

    it "does not raise an NotImplementedError" do
      expect { subject }.not_to raise_error
    end

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject.respond_to?(:call)).to be_truthy }
    end

    describe '#call' do
      let(:soap) { instance_double(Cocard::SOAP::GetCard) }
      let(:pinstatus) { double(Cocard::GetPinStatus) }
      describe "return error if not successful" do
        before(:each) do
          expect(Cocard::SOAP::GetCard).to receive(:new).and_return(soap)
          expect(soap).to receive(:call).and_return(fake_err)
          connector.update(soap_request_success: true)
        end

        it { expect(subject.call.success?).to be_falsey }
      end

      describe "successful call" do
        before(:each) do
          expect(Cocard::SOAP::GetCard).to receive(:new).and_return(soap)
          expect(Cocard::GetPinStatus).to receive(:new).and_return(pinstatus)
          expect(soap).to receive(:call).and_return(fake_ok)
          expect(pinstatus).to receive(:call).and_return(pin_ok)
        end
        it { expect(subject.call.success?).to be_truthy }
        it { expect(subject.call.card).to be_kind_of(::Card) }

        describe 'get some information' do
          let(:card) { subject.call.card }
          it { expect(card.card_handle).to eq('ee676b27-5b40-4a40-9c65-979cc3113a1e') }
          it { expect(card.card_type).to eq('SMC-B') }
          it { expect(card.iccsn).to eq('80276002711000000000') }
          it { card.reload; expect(card.card_terminal.ct_id).to eq('CT_ID_0176') }
          it { expect(card.slotid).to eq(3) }
          it { expect(card.insert_time.to_s).to eq('2024-03-26 15:33:03 UTC') }
          it { expect(card.card_holder_name).to eq("Doctor Who's Universe") }
          it { expect(card.expiration_date.to_s).to eq('2027-01-19') }
        end
      end
    end
  end
end
