require 'rails_helper'

module Cocard
  RSpec.describe CheckCertificateExpiration do
    # 
    #  create fake response for Cocard::Soap::ReadCardCertificate
    #
    let(:connector_yml) do
      File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector.sds')
    end

    let(:response_yml) do
      file = File.join(Rails.root, 'spec', 'fixtures', 'files', 'check_certificate_expiration_response.yml')
      File.read(file)
    end

    let(:fake_ok)  { Fake.new(true, [], 
                              YAML.unsafe_load(response_yml)) }
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
      Cocard::CheckCertificateExpiration.new(context: context, connector: connector)
    end

    it "does not raise an NotImplementedError" do
      expect { subject }.not_to raise_error
    end

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject.respond_to?(:call)).to be_truthy }
    end

    describe '#call' do
      let(:soap) { instance_double(Cocard::SOAP::CheckCertificateExpiration) }
      describe "return error if not successful" do
        before(:each) do
          expect(Cocard::SOAP::CheckCertificateExpiration).to receive(:new).and_return(soap)
          expect(soap).to receive(:call).and_return(fake_err)
        end

         it { expect(subject.call.success?).to be_falsey }
      end

      describe "successful call" do
        before(:each) do
          expect(Cocard::SOAP::CheckCertificateExpiration).to receive(:new).and_return(soap)
          expect(soap).to receive(:call).and_return(fake_ok)
        end
        it { expect(subject.call.success?).to be_truthy }
        it { expect(subject.call.cards).to be_kind_of(Array) }

        describe "cards" do
          let(:cards) { subject.call.cards }
          describe 'with real card' do
            let(:card) { cards[0] }
            it { expect(card.card_handle).to eq('20e81a27-92ce-4af0-b709-db8ac14c601b') }
            it { expect(card.ct_id).to eq('CT_ID_0176') }
            it { expect(card.iccsn).to eq("80276002711000059999")}
            it { expect(card.expiration_date.to_s).to eq("2026-08-15")}
            it { expect(card.is_connector_cert).to be_falsey }
          end

          describe 'with connector certificate' do
            let(:card) { cards[1] }
            it { expect(card.card_handle).to be_nil }
            it { expect(card.ct_id).to be_nil }
            it { expect(card.iccsn).to eq("80276003640000909999")}
            it { expect(card.expiration_date.to_s).to eq("2025-12-31")}
            it { expect(card.is_connector_cert).to be_truthy }
          end
        end
      end
    end
  end
end
