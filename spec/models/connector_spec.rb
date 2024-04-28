require 'rails_helper'

RSpec.describe Connector, type: :model do
  let(:yaml) do
    File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector_services.yaml')
  end
  let(:connector) do 
    FactoryBot.create(:connector, 
      ip: '127.0.0.1',
      connector_services: YAML.load_file(yaml)
    )
  end
  it { is_expected.to have_many(:contexts).through(:connector_contexts) }
  it { is_expected.to have_and_belong_to_many(:locations) }
  it { is_expected.to validate_presence_of(:ip) }

  it 'should get plain factory working' do
    f = FactoryBot.create(:connector)
    g = FactoryBot.create(:connector)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:ip)
  end

  describe "#to_s" do
    it { expect(connector.to_s).to match('- / 127.0.0.1') }
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
    it { expect(connector.condition).to eq(Cocard::States::NOTHING) }

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
        }.to change(connector, :condition).to(Cocard::States::UNKNOWN)
      end
    end

    describe "with vpnti_status offline" do
      it "-> WARNING" do
        expect(connector).to receive(:up?).and_return(true)
        expect(connector).to receive(:soap_request_success).and_return(true)
        expect(connector).to receive(:vpnti_online).and_return(false)
        expect {
          connector.update_condition
        }.to change(connector, :condition).to(Cocard::States::WARNING)
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

        it 'updates last_check_ok' do
          connector.soap_request_success = true
          connector.vpnti_online = true
          expect {
            connector.save
          }.to change(connector, :last_check_ok)
        end
      end
    end

    describe "#condition_message" do
      describe "with condition = CRITICAL" do
        before(:each) do
          expect(connector).to receive(:condition).and_return(Cocard::States::CRITICAL)
        end
        it { expect(connector.condition_message).to match(/CRITICAL/) }
      end
      describe "with condition = UNKNOWN" do
        before(:each) do
          expect(connector).to receive(:condition).and_return(Cocard::States::UNKNOWN)
        end
        it { expect(connector.condition_message).to match(/UNKNOWN/) }
      end
      describe "with condition = WARNING" do
        before(:each) do
          expect(connector).to receive(:condition).and_return(Cocard::States::WARNING)
        end
        it { expect(connector.condition_message).to match(/WARNING/) }
      end
      describe "with condition = OK" do
        before(:each) do
          expect(connector).to receive(:condition).and_return(Cocard::States::OK)
        end
        it { expect(connector.condition_message).to match(/OK/) }
      end
    end

  end
end
