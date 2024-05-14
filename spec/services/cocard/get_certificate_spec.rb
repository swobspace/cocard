require 'rails_helper'

module Cocard
  RSpec.describe GetCards do
    # 
    #  create fake response for Cocard::Soap::ReadCardCertificate
    #
    let(:connector_yml) do
      File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector.sds')
    end

    let(:certificate_yml) do
      file = File.join(Rails.root, 'spec', 'fixtures', 'files', 'read_card_certificate_response.yml')
      File.read(file)
    end

    let(:fake_ok)  { Fake.new(true, [], 
                              YAML.unsafe_load(certificate_yml)) }
    let(:fake_err) { Fake.new(false, ['something is wrong'], nil) }

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
    let(:connector_context) do
      ConnectorContext.create!(connector: connector, context: context)
    end

    #
    # card
    #
    let(:card) do
      FactoryBot.create(:card, card_handle: 'ee676b27-5b40-4a40-9c65-979cc3113a1e')
    end

    subject do
      Cocard::GetCertificate.new(connector_context: connector_context, card: card)
    end

    it "does not raise an NotImplementedError" do
      expect { subject }.not_to raise_error
    end

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject.respond_to?(:call)).to be_truthy }
    end

    describe '#call' do
      let(:soap) { instance_double(Cocard::SOAP::ReadCardCertificate) }
      describe "return error if not successful" do
        before(:each) do
          expect(Cocard::SOAP::ReadCardCertificate).to receive(:new).and_return(soap)
          expect(soap).to receive(:call).and_return(fake_err)
        end

         it { expect(subject.call.success?).to be_falsey }
      end

      describe "successful call" do
        before(:each) do
          expect(Cocard::SOAP::ReadCardCertificate).to receive(:new).and_return(soap)
          expect(soap).to receive(:call).and_return(fake_ok)
        end
        it { expect(subject.call.success?).to be_truthy }
        it { expect(subject.call.certificate).to be_kind_of(Cocard::Certificate) }

        describe 'get some information' do
          before(:each) do
            subject.call
          end
          it { expect(card.card_handle).to eq('ee676b27-5b40-4a40-9c65-979cc3113a1e') }
          it { expect(card.certificate).to match(/\AMIIFgTCCBGmgAwIBAgIDRmTb/) }
          # it { expect(card.cert).to be_kind_of(OpenSSL::X509::Certificate) }
          it { expect(card.name).to eq("Institutsambulanz - Dr. Lepping") }
          it { expect(card.cert_subject_cn).to eq("Institutsambulanz - Dr. Lepping") }
          it { expect(card.cert_subject_title).to eq("Dr. med.") }
          it { expect(card.cert_subject_sn).to eq("Lepping") }
          it { expect(card.cert_subject_givenname).to eq("Thomas") }
          it { expect(card.cert_subject_street).to eq("Mühlenstraße  31-35") }
          it { expect(card.cert_subject_postalcode).to eq("53518") }
          it { expect(card.cert_subject_l).to eq("Adenau") }
          it { expect(card.telematikid).to eq("1-20477412100") }
          it { expect(card.bsnr).to eq("477412100") }
        end
      end
    end
  end
end
