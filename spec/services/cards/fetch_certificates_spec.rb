require 'rails_helper'

module Cards
  RSpec.describe FetchCertificates do
    # 
    #  create fake response for Cocard::Soap::ReadCardCertificate
    #
    let(:connector_yml) do
      File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector_services.yaml')
    end

    let(:certificate_yml) do
      file = File.join(Rails.root, 'spec', 'fixtures', 'files', 'read_card_certificate_response_array.yml')
      File.read(file)
    end

    let(:fake_ok)  { Cocard::Fake.new(true, [], 
                              YAML.unsafe_load(certificate_yml)) }
    let(:fake_err) { Cocard::Fake.new(false, ['something is wrong'], nil) }

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

    #
    # card terminal
    #
    let(:ct) do
      FactoryBot.create(:card_terminal, :with_mac, connector: connector)
    end

    #
    # card
    #
    let(:card) do
      FactoryBot.create(:card, 
        card_terminal: ct,
        card_handle: 'ee676b27-5b40-4a40-9c65-979cc3113a1e',
        card_type: 'SMC-B'
      )
    end
    let(:context) { FactoryBot.create(:context) }

    subject do
      Cards::FetchCertificates.new(context: context, card: card)
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
      describe "if not successful" do
        before(:each) do
          expect(Cocard::SOAP::ReadCardCertificate).to receive(:new).at_least(:once).and_return(soap)
          expect(soap).to receive(:call).at_least(:once).and_return(fake_err)
        end
        it "returns an error" do
          called_back = false
          subject.call do |result|
            result.on_failure do |message|
              called_back = true
            end
          end
          expect(called_back).to be_truthy
        end
      end

      describe "with empty context" do
        let(:context) { nil }

        it "returns an error" do
          called_back = false
          subject.call do |result|
            result.on_failure do |message|
              called_back = true
              expect(message).to match("No Context assigned")
            end
          end
          expect(called_back).to be_truthy
        end
      end

      describe "successful call" do
        before(:each) do
          expect(Cocard::SOAP::ReadCardCertificate).to receive(:new).at_least(:once).and_return(soap)
          expect(soap).to receive(:call).at_least(:once).and_return(fake_ok)
        end

        it "creates certificates" do
          called_back = false
          subject.call do |result|
            result.on_success do |message, card_certificates|
              called_back = true
              expect(message).to match("Kartenzertifikate erfolgreich eingelesen")
              expect(card_certificates).to be_kind_of Array
              expect(card_certificates.first).to be_kind_of CardCertificate
            end
          end
          expect(called_back).to be_truthy
          card.reload
          # puts card.card_certificates.pluck(:cert_ref, :crypt, :expiration_date)
          expect(card.card_certificates.count).to eq(4)
        end

      end

    end
  end
end
