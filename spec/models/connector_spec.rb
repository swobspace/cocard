require 'rails_helper'

RSpec.describe Connector, type: :model do
  let(:yaml) do
    File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector_services.yaml')
  end
  let(:connector) do 
    FactoryBot.create(:connector, 
      ip: '127.0.0.9',
      connector_services: YAML.load_file(yaml)
    )
  end
  it { is_expected.to have_many(:logs) }
  it { is_expected.to have_many(:contexts).through(:connector_contexts) }
  it { is_expected.to have_many(:card_terminals).dependent(:restrict_with_error) }
  it { is_expected.to have_and_belong_to_many(:locations) }
  it { is_expected.to have_and_belong_to_many(:client_certificates) }
  it { is_expected.to validate_presence_of(:ip) }
  it { is_expected.to define_enum_for(:authentication).with_values(noauth: 0, clientcert: 1) }

  it 'should get plain factory working' do
    f = FactoryBot.create(:connector)
    g = FactoryBot.create(:connector)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:ip)
  end

  describe "#to_s" do
    it { expect(connector.to_s).to match('- / 127.0.0.9') }
  end

  describe "#product_information" do
    it { expect(connector.product_information).to be_kind_of(Cocard::ProductInformation) }
  end

  describe "#service_information" do
    it { expect(connector.service_information).to be_kind_of(Array) }
    it { expect(connector.service_information.first).to be_kind_of(Cocard::Service) }
  end

  describe "#service('EventService')" do
    it { expect(connector.service('EventService')).to be_kind_of(Cocard::Service) }
  end

  describe "#update_condition" do
    it { expect(connector.condition).to eq(Cocard::States::UNKNOWN) }

    describe "with manual check enabled" do
      it "-> NOTHING" do
        expect(connector).to receive(:manual_update).and_return(true)
        expect {
          connector.update_condition
        }.to change(connector, :condition).to(Cocard::States::NOTHING)
      end
    end

    describe "with ping failed" do
      it "-> CRITICAL" do
        expect(connector).to receive(:up?).and_return(false)
        expect {
          connector.update_condition
        }.to change(connector, :condition).to(Cocard::States::CRITICAL)
      end
    end

    describe "with soap request failed" do
      it "-> UKNOWN" do
        expect(connector).to receive(:up?).and_return(true)
        expect(connector).to receive(:soap_request_success).and_return(false)
        expect {
          connector.update_condition
        }.not_to change(connector, :condition)
      end
    end

    describe "with vpnti_status offline" do
      it "-> WARNING" do
        expect(connector).to receive(:up?).and_return(true)
        expect(connector).to receive(:soap_request_success).and_return(true)
        expect(connector).to receive(:vpnti_online).and_return(false)
        expect {
          connector.update_condition
        }.to change(connector, :condition).to(Cocard::States::CRITICAL)
      end
    end

    describe "with vpnti_status online" do
      it "-> CRITICAL" do
        expect(connector).to receive(:up?).and_return(true)
        expect(connector).to receive(:soap_request_success).and_return(true)
        expect(connector).to receive(:vpnti_online).and_return(true)
        expect {
          connector.update_condition
        }.to change(connector, :condition).to(Cocard::States::OK)
      end
    end

    describe "#save" do
      describe "with changed soap_request_success" do
        it "updates condition" do
          connector.soap_request_success = true
          expect {
            connector.save
          }.to change(connector, :condition)
        end

        it 'updates last_ok' do
          connector.soap_request_success = true
          connector.vpnti_online = true
          expect {
            connector.save
          }.to change(connector, :last_ok)
        end
      end

      describe "with empty sds_url" do
        let(:connector) { FactoryBot.build(:connector, ip: '127.0.0.42') }
        it "updates sds_url with default" do
          expect {
            connector.save
          }.to change(connector, :sds_url).to('http://127.0.0.42/connector.sds')
        end
      end

      describe "with empty admin_url" do
        let(:connector) { FactoryBot.build(:connector, ip: '127.0.0.42') }
        it "updates admin_url with default" do
          expect {
            connector.save
          }.to change(connector, :admin_url).to('https://127.0.0.42:9443')
        end
      end
    end
  end
end
