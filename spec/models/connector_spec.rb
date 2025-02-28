require 'rails_helper'

RSpec.describe Connector, type: :model do
  let(:yaml) do
    File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector_services.yaml')
  end
  let(:connector) do 
    FactoryBot.create(:connector, 
      ip: '127.1.2.3',
      connector_services: YAML.load_file(yaml)
    )
  end
  it { is_expected.to have_many(:logs) }
  it { is_expected.to belong_to(:acknowledge).optional }
  it { is_expected.to have_many(:notes).dependent(:destroy) }
  it { is_expected.to have_many(:plain_notes).dependent(:destroy) }
  it { is_expected.to have_many(:acknowledges).dependent(:destroy) }
  it { is_expected.to have_many(:contexts).through(:connector_contexts) }
  it { is_expected.to have_many(:card_terminals).dependent(:restrict_with_error) }
  it { is_expected.to have_and_belong_to_many(:locations) }
  it { is_expected.to have_and_belong_to_many(:client_certificates) }
  it { is_expected.to validate_presence_of(:ip) }
  it { is_expected.to define_enum_for(:authentication).with_values(noauth: 0, clientcert: 1, basicauth: 2) }

  it 'should get plain factory working' do
    f = FactoryBot.create(:connector)
    g = FactoryBot.create(:connector)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:ip)
    expect(f).to validate_uniqueness_of(:short_name)
  end

  describe "#to_s" do
    it { expect(connector.to_s).to match("- / 127.1.2.3") }
  end

  describe "with real connector data" do
    describe "#product_information" do
      it { expect(connector.product_information).to be_kind_of(Cocard::ProductInformation) }
    end

    describe "#identification" do
      it { expect(connector.identification).to eq("KOCOC-kocobox") }
    end

    describe "#service_information" do
      it { expect(connector.service_information).to be_kind_of(Array) }
      it { expect(connector.service_information.first).to be_kind_of(Cocard::Service) }
    end

    describe "#service('EventService')" do
      it { expect(connector.service('EventService')).to be_kind_of(Cocard::Service) }
    end
  end

  describe "with no data" do
    let(:connector) { FactoryBot.create(:connector) }
    describe "#product_information" do
      it { expect(connector.product_information).to be_kind_of(Cocard::ProductInformation) }
    end

    describe "#identification" do
      it { expect(connector.identification).to eq("-") }
    end

    describe "#service_information" do
      it { expect(connector.service_information).to be_kind_of(Array) }
      it { expect(connector.service_information.first).to be_nil }
    end

    describe "#service('EventService')" do
      it { expect(connector.service('EventService')).to be_nil }
    end
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

    describe "with reboot in progress" do
      it "-> WARNING" do
        expect(connector).to receive(:up?).and_return(false)
        expect(connector).to receive(:rebooted_at).at_least(:once).and_return(2.minutes.before(Time.current))
        expect {
          connector.update_condition
        }.to change(connector, :condition).to(Cocard::States::WARNING)
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
      it "-> CRITICAL" do
        expect(connector).to receive(:up?).and_return(true)
        expect(connector).to receive(:soap_request_success).and_return(true)
        expect(connector).to receive(:vpnti_online).and_return(false)
        expect {
          connector.update_condition
        }.to change(connector, :condition).to(Cocard::States::CRITICAL)
      end
    end

    describe "with expiring certificate" do
      it "-> CRITICAL" do
        expect(connector).to receive(:up?).and_return(true)
        expect(connector).to receive(:soap_request_success).and_return(true)
        expect(connector).to receive(:vpnti_online).and_return(true)
        expect(connector).to receive(:expiration_date).
               at_least(:once).and_return(1.month.after(Date.current))
        expect {
          connector.update_condition
        }.to change(connector, :condition).to(Cocard::States::WARNING)
      end
    end

    describe "with vpnti_status online" do
      let(:ack) do 
        FactoryBot.create(:note, notable: connector, 
          type: Note.types[:acknowledge]
        )
      end

      it "-> OK" do
        connector.update(acknowledge_id: ack.id, rebooted_at: 2.minutes.before(Time.current))
        connector.reload
        expect(connector.acknowledge).to eq(ack)
        expect(connector).to receive(:up?).at_least(:once).and_return(true)
        expect(connector).to receive(:soap_request_success).at_least(:once).and_return(true)
        expect(connector).to receive(:vpnti_online).at_least(:once).and_return(true)
        expect(connector).to receive(:expiration_date).
               at_least(:once).and_return(4.month.after(Date.current))
        expect {
          connector.update_condition
        }.to change(connector, :condition).to(Cocard::States::OK)
        connector.reload
        expect(connector.last_ok).to be >= 1.second.before(Time.current)
        expect(connector.acknowledge).to be_nil
        expect(connector.rebooted_at).to be_nil
        ack.reload
        expect(ack.valid_until).to be >= 1.second.before(Time.current)
        expect(ack.valid_until).to be <= 1.second.after(Time.current)
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

  describe "with notes" do
    let!(:note) { FactoryBot.create(:note, notable: connector, type: Note.types[:plain]) }
    let!(:ack) { FactoryBot.create(:note, notable: connector, type: Note.types[:acknowledge]) }
    let!(:oldnote) do
      FactoryBot.create(:note,
        notable: connector,
        type: Note.types[:plain],
        valid_until: Date.yesterday
      )
    end
    let!(:oldack) do
      FactoryBot.create(:note,
        notable: connector,
        type: Note.types[:acknowledge],
        valid_until: Date.yesterday
      )
    end

    it { expect(connector.acknowledges).to contain_exactly(ack, oldack) }
    it { expect(connector.current_acknowledge).to eq(ack) }
    it { expect(connector.acknowledges.active).to contain_exactly(ack) }
    it { expect(connector.acknowledges.count).to eq(2) }
    it { expect(connector.current_note).to eq(note) }
    it { expect(connector.notes.active).to contain_exactly(note, ack) }
    it { expect(connector.notes.count).to eq(4) }
    it { expect(connector.plain_notes).to contain_exactly(note, oldnote) }
    it { expect(connector.plain_notes.active).to contain_exactly(note) }
    it { expect(connector.plain_notes.count).to eq(2) }

    describe "#close_acknowledge" do
      before(:each) do
        connector.update(acknowledge_id: ack.id)
        connector.reload
      end

      it "terminates current ack" do
        expect(connector.acknowledge).to eq(ack)
        expect {
          connector.close_acknowledge
        }.to change(connector, :acknowledge_id).to(nil)
      end
    end
  end

  describe "#tcp_port_open?(8080)" do
    it { expect(connector.tcp_port_open?(8080)).to be_truthy }
  end
  # it {puts connector.sds_url}

end
