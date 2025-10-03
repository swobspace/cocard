require 'rails_helper'

RSpec.describe CardTerminal, type: :model do
  let!(:location) { FactoryBot.create(:location, lid: 'ACX') }
  let!(:network) do 
    FactoryBot.create(:network, 
      netzwerk: '127.2.3.0/24',
      location_id: location.id,
      accessibility: 'ping'
    )
  end
  let!(:location2) { FactoryBot.create(:location, lid: 'BB4') }
  let!(:network2) do 
    FactoryBot.create(:network, 
      netzwerk: '127.4.5.0/24',
      location_id: location2.id,
      accessibility: 'ping'
    )
  end
  let(:connector) { FactoryBot.create(:connector, short_name: 'K128') }
  let(:ct) do
    FactoryBot.create(:card_terminal,
      ip: '127.2.3.4',
      current_ip: '127.2.3.4',
      connector: connector,
      name: 'ACME Term',
      ct_id: 'CT_ID_0123',
      mac: '11:22:33:44:88:dd',
      location: location,
      network: network,
      connected: false,
      last_ok: Time.current
    )
  end

  it { is_expected.to have_many(:logs) }
  it { is_expected.to belong_to(:acknowledge).optional }
  it { is_expected.to have_many(:notes).dependent(:destroy) }
  it { is_expected.to have_many(:plain_notes).dependent(:destroy) }
  it { is_expected.to have_many(:acknowledges).dependent(:destroy) }
  it { is_expected.to have_many(:terminal_workplaces).dependent(:destroy) }
  it { is_expected.to have_many(:workplaces).through(:terminal_workplaces) }
  it { is_expected.to belong_to(:connector).optional }
  it { is_expected.to belong_to(:location).optional }
  it { is_expected.to belong_to(:network).optional }
  it { is_expected.to have_many(:card_terminal_slots).dependent(:destroy) }
  it { is_expected.to have_many(:cards).through(:card_terminal_slots) }
  it { is_expected.to have_many(:tags).through(:taggings) }
  # it { is_expected.to validate_presence_of(:mac) }
  it { is_expected.to define_enum_for(:pin_mode).with_values(off: 0, on_demand: 1, auto: 2) }

  it "validates if mac or serial is present" do
  end

  it 'should get plain factory working' do
    f = FactoryBot.create(:card_terminal, :with_mac, connector_id: connector.id)
    g = FactoryBot.create(:card_terminal, :with_sn)
    h = FactoryBot.build(:card_terminal)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(h).not_to be_valid
    expect(f).to validate_uniqueness_of(:ct_id).scoped_to(:connector_id)
    expect(f).to validate_uniqueness_of(:mac).case_insensitive.allow_nil
  end

  describe "#to_s" do
    it { expect(ct.to_s).to match('ACME Term (ACX)') }
  end

  describe "#fullname" do
    it { expect(ct.fullname).to match('K128: ACME Term (ACX)') }
  end

  describe "on #save" do
    it "adds missing displayname" do
      ct.displayname = ''
      ct.name = "New Name"
      expect {
        ct.save 
      }.to change(ct, :displayname).to ('New Name')
    end

    it "updates location from ip" do
      ct.update(ip: "127.4.5.19")
      ct.reload
      expect(ct.ip.to_s).to eq("127.4.5.19")
      expect(ct.location.lid).to eq(location2.lid)
    end

    it "doesn't update ip from current ip" do
      ct.update(current_ip: "127.4.5.19")
      ct.reload
      expect(ct.ip.to_s).to eq("127.2.3.4")
    end

    it "update ip from current ip if ip.nil?" do
      ct = FactoryBot.create(:card_terminal, :with_mac)
      expect(ct.ip).to be_nil
      ct.update(current_ip: "127.4.5.19")
      ct.reload
      expect(ct.ip.to_s).to eq("127.4.5.19")
    end
  end


  describe "product_information" do
    let(:prodinfo)  {{ product_information:
      {:information_date=> Time.current,
       :product_type_information=> {:product_type=>"KardTerm", :product_type_version=>"1.2.3.4"},
       :product_identification=> {
         :product_vendor_id=>"Heinrich GmbH",
         :product_code=>"HEINER4711",
         :product_version=> { :local=>{:hw_version=>"5.6.7", :fw_version=>"8.9.1"}}
       },
       :product_miscellaneous=> {:product_vendor_name=>nil, :product_name=>nil}}
    }}
    before(:each) do
      ct.update(properties: prodinfo)
    end

    it { expect(ct.product_information).to be_kind_of(Cocard::ProductInformation) }
    it { expect(ct.product_information.product_type_information).to include(
           :product_type=>"KardTerm", :product_type_version=>"1.2.3.4"
         )}

  end


  describe "#update_condition" do
    before(:each) do
    end

    describe "accessibility: ping" do
      it { expect(ct.condition).to eq(Cocard::States::WARNING) }

      describe "without connector" do
        it "-> NOTHING" do
          ct.update(condition: Cocard::States::OK)
          ct.reload
          expect(ct).to receive(:connector).and_return(nil)
          expect {
            ct.update_condition
          }.to change(ct, :condition).to(Cocard::States::NOTHING)
          expect(ct.condition_message).to match(/Kein Konnektor zugewiesen/)
        end
      end

      describe "with last_ok.blank?" do
        it "-> CRITICAL" do
          expect(ct).to receive(:last_ok).and_return(nil)
          expect {
            ct.update_condition
          }.to change(ct, :condition).to(Cocard::States::NOTHING)
          expect(ct.condition_message).to match(/Kartenterminal nicht in Betrieb/)
        end
      end

      describe "with ping failed, not connected" do
        it "-> CRITICAL" do
          expect(ct).to receive(:connected).and_return(false)
          expect(ct).to receive(:up?).at_least(:once).and_return(false)
          expect {
            ct.update_condition
          }.to change(ct, :condition).to(Cocard::States::CRITICAL)
          expect(ct.condition_message).to match(/CRITICAL Kartenterminal nicht erreichbar, kein Ping und nicht mit dem Konnektor verbunden/)
        end
      end

      describe "with ip 0.0.0.0, not connected" do
        it "-> UNKNOWN" do
          expect(ct).to receive(:ip).at_least(:once).and_return('0.0.0.0')
          expect(ct).to receive(:current_ip).at_least(:once).and_return('0.0.0.0')
          expect(ct).to receive(:connected).at_least(:once).and_return(false)
          expect(ct).to receive(:up?).at_least(:once).and_return(true)
          expect {
            ct.update_condition
          }.to change(ct, :condition).to(Cocard::States::UNKNOWN)
          expect(ct.condition_message).to match(/UNKNOWN Kartenterminal hat keine sinnvolle IP: 0.0.0.0/)
        end
      end

      describe "with ip mismatch" do
        it "-> UNKNOWN" do
          expect(ct).to receive(:ip).at_least(:once).and_return('127.2.3.8')
          expect(ct).to receive(:current_ip).at_least(:once).and_return('127.4.5.19')
          expect {
            ct.update_condition
          }.to change(ct, :condition).to(Cocard::States::UNKNOWN)
          expect(ct.condition_message).to match(/UNKNOWN IP Mismatch: gefundene IP \(127.4.5.19\) und konfigurierte IP \(127.2.3.8\) weichen von einander ab/)
        end
      end

      describe "with ping ok, but not connected" do
        it "-> WARNING" do
          expect(ct).to receive(:connected).at_least(:once).and_return(false)
          expect(ct).to receive(:up?).at_least(:once).and_return(true)
          ct.update_condition
          expect(ct.condition).to eq(Cocard::States::WARNING)
          expect(ct.condition_message).to match(/WARNING Kartenterminal per Ping erreichbar, aber nicht mit dem Konnektor verbunden/)
        end
      end

      describe "with ping failed, but connected" do
        it "-> WARNING" do
          expect(ct).to receive(:connected).at_least(:once).and_return(true)
          expect(ct).to receive(:up?).at_least(:once).and_return(false)
          ct.update_condition
          expect(ct.condition).to eq(Cocard::States::WARNING)
          expect(ct.condition_message).to match(/WARNING Kartenterminal mit dem Konnektor verbunden, aber Ping fehlgeschlagen/)
        end
      end

      describe "with connected online" do
        let(:ack) do 
          FactoryBot.create(:note, notable: ct, 
            type: Note.types[:acknowledge]
          )
        end

        it "-> OK" do
          ct.update(acknowledge_id: ack.id)
          ct.reload
          expect(ct.acknowledge).to eq(ack)
          expect(ct).to receive(:up?).at_least(:once).and_return(true)
          expect(ct).to receive(:connected).at_least(:once).and_return(true)
          expect {
            ct.update_condition
          }.to change(ct, :condition).to(Cocard::States::OK)
          expect(ct.condition_message).to match(/OK Kartenterminal online/)
          ct.reload
          expect(ct.acknowledge).to be_nil
          ack.reload
          expect(ack.valid_until).to be >= 1.second.before(Time.current)
          expect(ack.valid_until).to be <= 1.second.after(Time.current)
        end
      end

      describe "#save" do
        describe "with changed connected" do
          it "updates condition" do
            ct.connected = true
            expect {
              ct.save
            }.to change(ct, :condition)
          end
        end
      end
    end

    describe "accessibility: nothing" do
      before(:each) do
        ct.update(network_id: nil)
      end
      it { expect(ct.condition).to eq(Cocard::States::CRITICAL) }

      describe "without connector" do
        it "-> NOTHING" do
          ct.update(condition: Cocard::States::OK)
          ct.reload
          expect(ct).to receive(:connector).and_return(nil)
          expect {
            ct.update_condition
          }.to change(ct, :condition).to(Cocard::States::NOTHING)
          expect(ct.condition_message).to match(/Kein Konnektor zugewiesen/)
        end
      end

      describe "with last_ok.blank?" do
        it "-> CRITICAL" do
          expect(ct).to receive(:last_ok).and_return(nil)
          expect {
            ct.update_condition
          }.to change(ct, :condition).to(Cocard::States::NOTHING)
          expect(ct.condition_message).to match(/Kartenterminal nicht in Betrieb/)
        end
      end

      describe "with connected online" do
        it "-> OK" do
          expect(ct).to receive(:connected).and_return(true)
          expect {
            ct.update_condition
          }.to change(ct, :condition).to(Cocard::States::OK)
          expect(ct.condition_message).to match(/OK Kartenterminal online/)
        end
      end
    end
  end

  describe "#mac" do
    it { expect(ct.mac).to eq ('1122334488DD') }
  end

  describe "#online?" do
    context "is accessible" do
      before(:each) do
        expect(ct).to receive(:is_accessible?).and_return(true)
      end
      it "ping and connected: online == true" do
        expect(ct).to receive(:up?).and_return(true)
        expect(ct).to receive(:connected).and_return(true)
        expect(ct.online?).to be_truthy
      end
      it "no ping == false" do
        expect(ct).to receive(:up?).and_return(false)
        allow(ct).to receive(:connected).and_return(true)
        expect(ct.online?).to be_falsey
      end
      it "not connected: online == false" do
        expect(ct).to receive(:up?).and_return(true)
        expect(ct).to receive(:connected).and_return(false)
        expect(ct.online?).to be_falsey
      end
    end

    context "is not accessible" do
      before(:each) do
        expect(ct).to receive(:is_accessible?).and_return(false)
      end
      it "connected: online == true" do
        expect(ct).to receive(:connected).and_return(true)
        expect(ct.online?).to be_truthy
      end
      it "not connected: online == false" do
        expect(ct).to receive(:connected).and_return(false)
        expect(ct.online?).to be_falsey
      end
    end
  end
  describe "with notes" do
    let!(:note) { FactoryBot.create(:note, notable: ct, type: Note.types[:plain]) }
    let!(:ack) { FactoryBot.create(:note, notable: ct, type: Note.types[:acknowledge]) }
    let!(:oldnote) do
      FactoryBot.create(:note,
        notable: ct,
        type: Note.types[:plain],
        valid_until: Date.yesterday
      )
    end
    let!(:oldack) do
      FactoryBot.create(:note,
        notable: ct,
        type: Note.types[:acknowledge],
        valid_until: Date.yesterday
      )
    end

    it { expect(ct.acknowledges).to contain_exactly(ack, oldack) }
    it { expect(ct.current_acknowledge).to eq(ack) }
    it { expect(ct.acknowledges.active).to contain_exactly(ack) }
    it { expect(ct.acknowledges.count).to eq(2) }
    it { expect(ct.current_note).to eq(note) }
    it { expect(ct.notes.active).to contain_exactly(note, ack) }
    it { expect(ct.notes.count).to eq(4) }
    it { expect(ct.plain_notes).to contain_exactly(note, oldnote) }
    it { expect(ct.plain_notes.active).to contain_exactly(note) }
    it { expect(ct.plain_notes.count).to eq(2) }

    it "sets acknowledge_id" do
      expect {
        ct.save
      }.to change(ct, :acknowledge_id)
    end

    describe "#close_acknowledge" do
      before(:each) do
        ct.update(acknowledge_id: ack.id)
        ct.reload
      end

      it "terminates current ack" do
        expect(ct.acknowledge).to eq(ack)
        expect {
          ct.close_acknowledge
        }.to change(ct, :acknowledge_id).to(nil)
      end

      it "deletes acknowledge_id" do
        expect(ct.acknowledge).to eq(ack)
        ack.update(valid_until: 1.minute.before(Time.current))
        ct.save
        expect(ct.acknowledge_id).to be(nil)
      end

    end
  end

  describe "#noip?" do
    describe "with real ip" do
      before(:each) do
        expect(ct).to receive(:ip).at_least(:once).and_return('192.0.2.17')
      end
      it { expect(ct.noip?).to be_falsey }
    end

    describe "with 0.0.0.0" do
      before(:each) do
        expect(ct).to receive(:ip).at_least(:once).and_return('0.0.0.0')
      end
      it { expect(ct.noip?).to be_truthy }
    end

    describe "with 127.0.0.4" do
      before(:each) do
        expect(ct).to receive(:ip).at_least(:once).and_return('127.0.0.4')
      end
      it { expect(ct.noip?).to be_truthy }
    end
  end

  describe "removing connector" do
    before(:each) do 
      ct.update(connected: true)
      ct.reload
    end
    it "resets ct_id and current_ip" do
      ct.update(connector_id: nil)
      ct.reload
      expect(ct.ct_id).to be_blank
      expect(ct.current_ip).to be_nil
      expect(ct.connected).to be_falsey
    end
  end
end
