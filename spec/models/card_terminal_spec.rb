require 'rails_helper'

RSpec.describe CardTerminal, type: :model do
  let(:location) { FactoryBot.create(:location, lid: 'ACX') }
  let(:connector) { FactoryBot.create(:connector) }
  let(:ct) do
    FactoryBot.create(:card_terminal,
      ip: '127.0.0.9',
      connector: connector,
      name: 'ACME Term',
      ct_id: 'CT_ID_0123',
      mac: '11:22:33:44:88:dd',
      location: location,
      last_ok: Time.current
    )
  end
  it { is_expected.to have_many(:logs) }
  it { is_expected.to have_many(:terminal_workplaces).dependent(:destroy) }
  it { is_expected.to have_many(:workplaces).through(:terminal_workplaces) }
  it { is_expected.to belong_to(:connector).optional }
  it { is_expected.to belong_to(:location).optional }
  it { is_expected.to belong_to(:network).optional }
  it { is_expected.to have_many(:cards).dependent(:destroy) }
  # it { is_expected.to validate_presence_of(:mac) }

  it "validates if mac or serial is present" do
  end

  it 'should get plain factory working' do
    f = FactoryBot.create(:card_terminal, :with_mac)
    g = FactoryBot.create(:card_terminal, :with_sn)
    h = FactoryBot.build(:card_terminal)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(h).not_to be_valid
    expect(f).to validate_uniqueness_of(:ct_id).scoped_to(:connector_id)
  end

  describe "#to_s" do
    it { expect(ct.to_s).to match('ACME Term - CT_ID_0123 (ACX)') }
  end

  describe "on #save" do
    it "adds missing displayname" do
      ct.displayname = ''
      ct.name = "New Name"
      expect {
        ct.save 
      }.to change(ct, :displayname).to ('New Name')
    end
  end


  describe "product_information" do
    let(:prodinfo)  {{ product_information:
      {:information_date=> Time.current,
       :product_type_information=> {:product_type=>"KardTerm", :product_type_version=>"1.2.3.4"},
       :product_identification=> {
         :product_vendor_id=>"Heinrich GmbH",
         :product_code=>nil,
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
    it { expect(ct.condition).to eq(Cocard::States::WARNING) }

    describe "without connector" do
      it "-> NOTHING" do
        ct.update(condition: Cocard::States::OK)
        ct.reload
        expect(ct).to receive(:connector).and_return(nil)
        expect {
          ct.update_condition
        }.to change(ct, :condition).to(Cocard::States::NOTHING)
        expect(ct.condition_message).to match(/No connector assigned/)
      end
    end

    describe "with last_ok.blank?" do
      it "-> CRITICAL" do
        expect(ct).to receive(:last_ok).and_return(nil)
        expect {
          ct.update_condition
        }.to change(ct, :condition).to(Cocard::States::NOTHING)
        expect(ct.condition_message).to match(/CardTerminal noch nicht in Betrieb/)
      end
    end

    describe "with ping failed, not connected" do
      it "-> CRITICAL" do
        expect(ct).to receive(:connected).and_return(false)
        expect(ct).to receive(:up?).and_return(false)
        expect {
          ct.update_condition
        }.to change(ct, :condition).to(Cocard::States::CRITICAL)
        expect(ct.condition_message).to match(/CardTerminal unreachable - ping failed and not connected/)
      end
    end

    describe "with ping ok, but not connected" do
      it "-> WARNING" do
        expect(ct).to receive(:connected).and_return(false)
        expect(ct).to receive(:up?).and_return(true)
        ct.update_condition
        expect(ct.condition).to eq(Cocard::States::WARNING)
        expect(ct.condition_message).to match(/CardTerminal reachable, but not connected/)
      end
    end

    describe "with ping failed, but connected" do
      it "-> WARNING" do
        expect(ct).to receive(:connected).at_least(:once).and_return(true)
        expect(ct).to receive(:up?).and_return(false)
        ct.update_condition
        expect(ct.condition).to eq(Cocard::States::WARNING)
        expect(ct.condition_message).to match(/CardTerminal is connected, but ping failed/)
      end
    end

    describe "with connected online" do
      it "-> OK" do
        expect(ct).to receive(:up?).and_return(true)
        expect(ct).to receive(:connected).and_return(true)
        expect {
          ct.update_condition
        }.to change(ct, :condition).to(Cocard::States::OK)
        expect(ct.condition_message).to match(/CardTerminal online/)
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

  describe "#mac" do
    it { expect(ct.mac).to eq ('1122334488DD') }
  end
end
