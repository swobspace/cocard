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
    let(:ber) { FactoryBot.create(:location, lid: 'BER') }
    let!(:ct1) do
      FactoryBot.create(:card_terminal, :with_mac,
        displayname: 'QUORA - test',
        name: 'KLG-AXC-17',
        description: "some more infos",
        ip: '198.51.100.17',
        condition: 0,
        connected: true,
        firmware_version: '5.3.4',
        location: ber,
        supplier: 'ACME Ltd. International',
      )
    end

    let!(:ct2) do
      FactoryBot.create(:card_terminal,
        name: 'KLG-CWZ-04',
        ip: '203.0.113.4',
        ct_id: 'CT_ID_0124',
        condition: 2,
        firmware_version: '4.9.3',
        mac: '11:22:33:44:55:66',
        supplier: 'ACME Ltd. International',
      )
    end

    let!(:ct3) do
      FactoryBot.create(:card_terminal, :with_mac,
        name: 'KLG-CWZ-05',
        ip: '198.50.100.5',
        condition: 3,
        firmware_version: '4.9.3',
        room: 'U.16',
        contact: 'Dr.Who',
        plugged_in: 'Switch 17/4',
        supplier: 'ACME Ltd. International',
      )
    end

    let(:card_terminals) { CardTerminal.left_outer_joins(:location).all }

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

    context "with :lid" do
      subject { Query.new(card_terminals, {lid: 'ber'}) }
      before(:each) do
        @matching = [ct1]
        @nonmatching = [ct2, ct3]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :ip" do
      subject { Query.new(card_terminals, {ip: '203.0.113.'}) }
      before(:each) do
        @matching = [ct2]
        @nonmatching = [ct1, ct3]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :mac" do
      subject { Query.new(card_terminals, {mac: '22:33:44:'}) }
      before(:each) do
        @matching = [ct2]
        @nonmatching = [ct1, ct3]
      end
      it_behaves_like "a card_terminal query"
    end

    context "with :condition" do
      subject { Query.new(card_terminals, {condition: 2}) }
      before(:each) do
        @matching = [ct2]
        @nonmatching = [ct1, ct3]
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
          search = Query.new(card_terminals, {search: '203.0.113.'})
          expect(search.all).to contain_exactly(ct2)
        end

        it "searches for mac" do
          search = Query.new(card_terminals, {search: '22:33:44'})
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
