require 'rails_helper'

module CardTerminals
  RSpec.shared_examples "a card_terminal query" do
    describe "#all" do
      it { expect(subject.all).to contain_exactly(*@matching) }
    end
    describe "#find_each" do
      it "iterates over matching events" do
        a = []
        subject.find_each do |act|
          a << act
        end
        expect(a).to contain_exactly(*@matching)
      end
    end
    describe "#include?" do
      it "includes only matching events" do
        @matching.each do |ma|
          expect(subject.include?(ma)).to be_truthy
        end
        @nonmatching.each do |noma|
          expect(subject.include?(noma)).to be_falsey
        end
      end
    end
  end

  RSpec.describe Query do
    let(:tag) { FactoryBot.create(:tag, name: 'MyTag') }
    let(:ts)  { Time.parse("2025-03-11 12:00:00") }
    let(:ber) { FactoryBot.create(:location, lid: 'BER') }
    let(:network) { FactoryBot.create(:network, netzwerk: '127.51.0.0/16', location: ber) }
    let(:conn) { FactoryBot.create(:connector, name: 'TIK-127') }
    let(:card) do
      FactoryBot.create(:card, 
        card_type: 'SMC-KT', 
        iccsn: '802761234567',
        expiration_date: '2025-11-27',
      )
    end
    let!(:ct1) do
      FactoryBot.create(:card_terminal, :with_mac,
        displayname: 'QUORA - test',
        name: 'KLG-AXC-17',
        description: "some more infos",
        ip: '127.51.100.17',
        current_ip: '127.51.100.17',
        condition: 0,
        condition_message: "Condition Message",
        idle_message: "Willkommen!",
        connected: true,
        firmware_version: '5.3.4',
        location: ber,
        supplier: 'ACME Ltd. International',
        delivery_date: '2020-03-01',
        last_ok: ts,
        last_check: 1.week.after(ts),
        network: network,
        pin_mode: :on_demand,
      )
    end

    let!(:ct2) do
      FactoryBot.create(:card_terminal,
        name: 'KLG-CWZ-04',
        ip: '127.203.113.4',
        current_ip: '127.203.113.4',
        idle_message: "Willkommen!",
        ct_id: 'CT_ID_0124',
        condition: 2,
        firmware_version: '4.9.3',
        mac: '11:22:33:44:55:66',
        supplier: 'ACME Ltd. International',
        connector: conn,
        last_ok: ts - 1.week,
        last_check: 1.week.after(ts),
        network: network,
        pin_mode: :on_demand,
      )
    end

    let!(:ct3) do
      FactoryBot.create(:card_terminal, :with_mac,
        name: 'KLG-CWZ-05',
        ip: '127.50.100.5',
        current_ip: '127.50.100.5',
        condition: 3,
        firmware_version: '4.9.3',
        room: 'U.16',
        contact: 'Dr.Who',
        plugged_in: 'Switch 17/4',
        supplier: 'ACME Ltd. International',
        last_ok: ts - 1.month,
        last_check: Time.current,
        network: network,
      )
    end

    let!(:card_slot) do
      FactoryBot.create(:card_terminal_slot, 
        slotid: 4,
        card: card,
        card_terminal: ct2
      )
    end

    let!(:ack1) do
      FactoryBot.create(:note,
        type: :acknowledge,
        notable_type: 'CardTerminal',
        notable_id: ct1.id,
      )
    end

    let(:card_terminals) { CardTerminal.left_outer_joins(:location, :connector, card_terminal_slots: :card).all }

    # check for class methods
    it { expect(Query.respond_to? :new).to be_truthy}

    it "raise an ArgumentError" do
    expect {
      Query.new
    }.to raise_error(ArgumentError)
    end

   # check for instance methods
    describe "instance methods" do
      subject { Query.new(card_terminals) }
      it { expect(subject.respond_to? :all).to be_truthy}
      it { expect(subject.respond_to? :find_each).to be_truthy}
      it { expect(subject.respond_to? :include?).to be_truthy }
    end

   context "with unknown option :fasel" do
      subject { Query.new(card_terminals, {fasel: 'blubb'}) }
      describe "#all" do
        it "raises a argument error" do
          expect { subject.all }.to raise_error(ArgumentError)
        end
      end
    end

    context "with :id" do
      subject { Query.new(card_terminals, {id: ct1.to_param}) }
      before(:each) do
        @matching = [ct1]
        @nonmatching = [ct2, ct3]
      end
      it_behaves_like "a card_terminal query"
    end # :id

    context "with :displayname" do
      subject { Query.new(card_terminals, {displayname: "quora"}) }
      before(:each) do
        @matching = [ct1]
        @nonmatching = [ct2, ct3]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :name" do
      subject { Query.new(card_terminals, {name: "klg"}) }
      before(:each) do
        @matching = [ct1, ct2, ct3]
        @nonmatching = []
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :ct_id" do
      subject { Query.new(card_terminals, {ct_id: "0124"}) }
      before(:each) do
        @matching = [ct2]
        @nonmatching = [ct1, ct3]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :connector" do
      subject { Query.new(card_terminals, {connector: "tik"}) }
      before(:each) do
        @matching = [ct2]
        @nonmatching = [ct1, ct3]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :description" do
      subject { Query.new(card_terminals, {description: "more info"}) }
      before(:each) do
        @matching = [ct1]
        @nonmatching = [ct2, ct3]
      end
      it_behaves_like "a card_terminal query"
    end # :description

    context "with :room" do
      subject { Query.new(card_terminals, {room: "U.16"}) }
      before(:each) do
        @matching = [ct3]
        @nonmatching = [ct1, ct2]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :contact" do
      subject { Query.new(card_terminals, {contact: "Dr.Who"}) }
      before(:each) do
        @matching = [ct3]
        @nonmatching = [ct1, ct2]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :plugged_in" do
      subject { Query.new(card_terminals, {plugged_in: "Switch 17/4"}) }
      before(:each) do
        @matching = [ct3]
        @nonmatching = [ct1, ct2]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :supplier" do
      subject { Query.new(card_terminals, {supplier: "acme ltd"}) }
      before(:each) do
        @matching = [ct1, ct2, ct3]
        @nonmatching = []
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :last_ok" do
      subject { Query.new(card_terminals, {last_ok: '2025-03'}) }
      before(:each) do
        @matching = [ct1, ct2]
        @nonmatching = [ct3]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :last_check" do
      subject { Query.new(card_terminals, {last_check: '25-03-18'}) }
      before(:each) do
        @matching = [ct1, ct2]
        @nonmatching = [ct3]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :delivery date" do
      subject { Query.new(card_terminals, {delivery_date: '2020-03'}) }
      before(:each) do
        @matching = [ct1]
        @nonmatching = [ct2, ct3]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :lid" do
      subject { Query.new(card_terminals, {lid: 'ber'}) }
      before(:each) do
        @matching = [ct1]
        @nonmatching = [ct2, ct3]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :location_id" do
      subject { Query.new(card_terminals, {location_id: ber.id}) }
      before(:each) do
        @matching = [ct1]
        @nonmatching = [ct2, ct3]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :tag" do
      subject { Query.new(card_terminals, {tag: 'my'}) }
      before(:each) do
        ct1.tags << tag
        ct1.reload
        @matching = [ct1]
        @nonmatching = [ct2, ct3]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :ip" do
      subject { Query.new(card_terminals, {ip: '127.203.113.'}) }
      before(:each) do
        @matching = [ct2]
        @nonmatching = [ct1, ct3]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :mac" do
      subject { Query.new(card_terminals, {mac: '223344'}) }
      before(:each) do
        @matching = [ct2]
        @nonmatching = [ct1, ct3]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :condition 0" do
      subject { Query.new(card_terminals, {condition: 1}) }
      before(:each) do
        @matching = [ct2]
        @nonmatching = [ct1, ct3]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :condition 0" do
      subject { Query.new(card_terminals, {condition: "WARN"}) }
      before(:each) do
        @matching = [ct2]
        @nonmatching = [ct1, ct3]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :condition_message" do
      subject { Query.new(card_terminals, {condition_message: "Kein Konnektor zugewiesen"}) }
      before(:each) do
        @matching = [ct1, ct3]
        @nonmatching = [ct2]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :idle_messsage" do
      subject { Query.new(card_terminals, {idle_message: "willkommen"}) }
      before(:each) do
        @matching = [ct1, ct2]
        @nonmatching = [ct3]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :connected" do
      subject { Query.new(card_terminals, {connected: true}) }
      before(:each) do
        @matching = [ct1]
        @nonmatching = [ct2, ct3]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :firmware_version" do
      subject { Query.new(card_terminals, {firmware_version: '4.9'}) }
      before(:each) do
        @matching = [ct2, ct3]
        @nonmatching = [ct1]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :pin_mode" do
      subject { Query.new(card_terminals, {pin_mode: 'dema'}) }
      before(:each) do
        @matching = [ct1, ct2]
        @nonmatching = [ct3]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :iccsn" do
      subject { Query.new(card_terminals, {iccsn: '3456'}) }
      before(:each) do
        @matching = [ct2]
        @nonmatching = [ct1, ct3]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :expiration_date" do
      subject { Query.new(card_terminals, {expiration_date: '2025-11'}) }
      before(:each) do
        @matching = [ct2]
        @nonmatching = [ct1, ct3]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with outdated: true" do
      subject { Query.new(card_terminals, {outdated: 'true'}) }
      before(:each) do
        @matching = [ct1, ct2]
        @nonmatching = [ct3]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with acknowledged: true" do
      subject { Query.new(card_terminals, {acknowledged: 1}) }
      before(:each) do
        @matching = [ct1]
        @nonmatching = [ct2, ct3]
        ct1.update_acknowledge_id; ct1.save
      end
      it { puts CardTerminal.acknowledged }
      it_behaves_like "a card_terminal query"
    end

    context "with acknowledged: false" do
      subject { Query.new(card_terminals, {acknowledged: 0}) }
      before(:each) do
        @matching = [ct2, ct3]
        @nonmatching = [ct1]
        ct1.update_acknowledge_id; ct1.save
      end
      it_behaves_like "a card_terminal query"
    end

    context "with failed: true" do
      subject { Query.new(card_terminals, {failed: true}) }
      before(:each) do
        @matching = [ct2]
        @nonmatching = [ct1, ct3]
      end
      it { puts CardTerminal.pluck(:condition) }
      it_behaves_like "a card_terminal query"
    end

    describe "#all" do
      context "using :search'" do
        it "searches for displayname" do
          search = Query.new(card_terminals, {search: 'quora'})
          expect(search.all).to contain_exactly(ct1)
        end

        it "searches for name" do
          search = Query.new(card_terminals, {search: 'cwz'})
          expect(search.all).to contain_exactly(ct2, ct3)
        end

        it "searches for ct_id" do
          search = Query.new(card_terminals, {search: '0124'})
          expect(search.all).to contain_exactly(ct2)
        end

        it "searches for room" do
          search = Query.new(card_terminals, {search: 'U.16'})
          expect(search.all).to contain_exactly(ct3)
        end

        it "searches for contact" do
          search = Query.new(card_terminals, {search: 'Dr.Who'})
          expect(search.all).to contain_exactly(ct3)
        end

        it "searches for plugged_in" do
          search = Query.new(card_terminals, {search: 'Switch 17/4'})
          expect(search.all).to contain_exactly(ct3)
        end

        it "searches for supplier" do
          search = Query.new(card_terminals, {search: 'acme'})
          expect(search.all).to contain_exactly(ct1, ct2, ct3)
        end

        it "searches for ip" do
          search = Query.new(card_terminals, {search: '127.203.113.'})
          expect(search.all).to contain_exactly(ct2)
        end

        it "searches for mac" do
          search = Query.new(card_terminals, {search: '22:33:44'})
          puts CardTerminal.pluck(:mac)
          expect(search.all).to contain_exactly(ct2)
        end

        it "searches for mac without :" do
          search = Query.new(card_terminals, {search: '223344'})
          expect(search.all).to contain_exactly(ct2)
        end

        it "searches for firmware_version" do
          search = Query.new(card_terminals, {search: '4.9.'})
          expect(search.all).to contain_exactly(ct2, ct3)
        end


      end
    end
  end
end
