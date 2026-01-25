require 'rails_helper'

module Cocard::SOAP
  RSpec.describe GetCards do
    let(:yaml) do
      File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector_services.yaml')
    end
    let(:connector) do
      FactoryBot.create(:connector,
        ip: ENV['SDS_IP'],
        use_tls: ENV['USE_TLS'] || false,
        authentication: ENV['AUTHENTICATION'] || 'noauth',
        auth_user: ENV['AUTH_USER'],
        auth_password: ENV['AUTH_PASSWORD'],
        connector_services: YAML.load_file(yaml)
      )
    end

    let(:clientcert) do
      FactoryBot.create(:client_certificate,
        name: 'myname',
        cert: File.read(ENV['CLIENT_CERT_FILE']),
        pkey: File.read(ENV['CLIENT_PKEY_FILE']),
        passphrase: ENV['CLIENT_CERT_PASSPHRASE'] 
      ) 
    end   

    before(:each) do
      connector.client_certificates << clientcert
      connector.reload
    end

    describe "mandant_wide" do
      subject do
        Cocard::SOAP::GetCards.new(
          connector: connector,
          mandant: ENV['CONN_MANDANT'],
          client_system: ENV['CONN_CLIENT_SYSTEM_ID'],
          workplace: ENV['CONN_WORKPLACE_ID']
        )
      end

      it { expect(subject.soap_message).to include("CCTX:Context" => {"CONN:MandantId" => "cocard", "CONN:ClientSystemId" => "cocard", "CONN:WorkplaceId" => "Konnektor"}) }
      it { expect(subject.mandant_wide).to be_truthy }

      it "does not raise an NotImplementedError" do
        expect { subject }.not_to raise_error
      end

      # check for instance methods
      describe 'check if instance methods exists' do
        it { expect(subject.respond_to?(:call)).to be_truthy }
      end

      # must be explicit called with rspec --tag soap
      describe '#call', :soap => true do
        describe "return error if not successful" do
          let(:result) do
            Cocard::SOAP::GetCards.new(
              connector: connector,
              mandant: 'dontexist',
              client_system: 'dontexist',
              workplace: 'dontexist'
            ).call
          end
          it { expect(result.success?).to be_falsey }

          if ENV['USE_TLS'] && ENV['AUTHENTICATION'] == 'clientcert'
            it { expect(result.error_messages.join(",")).to match(/Clientsystem aus dem Aufrufkontext konnte nicht authentifiziert werden/) }
          elsif ENV['AUTHENTICATION'] == 'basicauth'
            it { expect(result.error_messages).to contain_exactly(
                 "Clientsystem aus dem Aufrufkontext konnte nicht authentifiziert werden.",
                 "S:Server", "code: 4204") }
          else
            it { expect(result.error_messages).to contain_exactly(
                   "S:Server", "Ungültige Mandanten-ID")}
          end
        end

        describe "successful call" do
          let(:result) { subject.call }
          it { pp  result.response }

          it { expect(result.success?).to be_truthy }
          it { expect(result.response.keys).to contain_exactly(:get_cards_response) }
        end
      end
    end

    describe "with ct_id" do
      subject do
        Cocard::SOAP::GetCards.new(
          connector: connector,
          mandant: ENV['CONN_MANDANT'],
          client_system: ENV['CONN_CLIENT_SYSTEM_ID'],
          workplace: ENV['CONN_WORKPLACE_ID'],
          ct_id: ENV['CT_ID']
        )
      end

      # it { puts subject.soap_message }
      it { expect(subject.soap_message).to include("CCTX:Context" => {"CONN:MandantId" => "cocard", "CONN:ClientSystemId" => "cocard", "CONN:WorkplaceId" => "Konnektor"}, "CARDCMN:CtId" => "#{ENV['CT_ID']}") }
      it { expect(subject.mandant_wide).to be_falsey }
    end
  end
end
