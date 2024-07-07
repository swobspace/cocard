require 'rails_helper'

module Cocard
  RSpec.describe GetCards do
    # 
    #  create fake response for Cocard::Soap::GetCards
    #
    let(:connector_yml) do
      File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector.sds')
    end

    let(:cards_yml) do
      file = File.join(Rails.root, 'spec', 'fixtures', 'files', 'get_cards_response.yml')
      File.read(file)
    end

    let(:fake_ok)  { Fake.new(true, [], 
                              YAML.unsafe_load(cards_yml)) }
    let(:fake_err) { Fake.new(false, ['something is wrong'], nil) }

    #
    # connector and context
    #
    let(:connector) do
      FactoryBot.create(:connector,
        ip: ENV['SDS_IP'],
        connector_services: YAML.load_file(connector_yml),
        vpnti_online: true
      )
    end

    let(:context) { FactoryBot.create(:context) }

    subject do
      Cocard::GetCards.new(connector: connector, context: context)
    end

    it "does not raise an NotImplementedError" do
      expect { subject }.not_to raise_error
    end

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject.respond_to?(:call)).to be_truthy }
    end

    describe '#call' do
      let(:soap) { instance_double(Cocard::SOAP::GetCards) }
      describe "return error if not successful" do
        before(:each) do
          expect(Cocard::SOAP::GetCards).to receive(:new).and_return(soap)
          expect(soap).to receive(:call).and_return(fake_err)
          connector.update(soap_request_success: true)
        end

        it { expect(subject.call.success?).to be_falsey }

        describe "Ping failed" do
          it "update connector_condition" do
            expect(connector).to receive(:up?).and_return(false)
            expect {
              subject.call
            }.to change(connector, :condition).to(Cocard::States::CRITICAL)
          end
        end

        describe "Ping ok" do
          it "update connector_condition" do
            expect(connector).to receive(:up?).and_return(true)
            expect {
              subject.call
            }.to change(connector, :condition).to(Cocard::States::UNKNOWN)
          end
        end
      end

      describe "successful call" do
        before(:each) do
          expect(Cocard::SOAP::GetCards).to receive(:new).and_return(soap)
          expect(soap).to receive(:call).and_return(fake_ok)
        end
        it { expect(subject.call.success?).to be_truthy }
        it { expect(subject.call.cards.last).to be_kind_of(Cocard::Card) }
        it 'updates last_check' do
          expect do
            subject.call
          end.to change(connector, :last_check)
        end

        it 'updates last_ok' do
          expect do
            subject.call
          end.to change(connector, :last_ok)
        end

        describe 'get some information' do
          let(:ct) { subject.call.cards.last }
          it { expect(ct.card_handle).to eq('ee676b27-5b40-4a40-9c65-979cc3113a1e') }
          it { expect(ct.card_type).to eq('SMC-B') }
          it { expect(ct.iccsn).to eq('80276002711000000000') }
          it { expect(ct.ct_id).to eq('CT_ID_0176') }
          it { expect(ct.slotid).to eq(1) }
          it { expect(ct.insert_time.to_s).to eq('2024-03-26T15:33:03+00:00') }
          it { expect(ct.card_holder_name).to eq("Doctor Who's Universe") }
          it { expect(ct.expiration_date.to_s).to eq('2027-01-19') }
        end
      end
    end
  end
end
