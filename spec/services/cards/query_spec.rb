require 'rails_helper'

module Cards
  RSpec.shared_examples "a card query" do
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
    let(:ber) { FactoryBot.create(:location, lid: 'BER') }
    let(:conn) { FactoryBot.create(:connector) }
    let(:ct)  { FactoryBot.create(:card_terminal, :with_mac, connector: conn, location: ber) }
    let(:opsta) { FactoryBot.create(:operational_state, name: 'in Betrieb', operational: true) }
    let(:ctx) { FactoryBot.create(:context) }
    let!(:card1) do
      FactoryBot.create(:card,
        name: 'SMC-B 0001',
        description: "some more infos",
        card_type: 'SMC-B',
        location: ber,
        object_system_version: '4.4.0',
        iccsn: '9990001',
        operational_state: opsta,
        card_terminal: ct,
        expiration_date: 1.day.before(Date.current),
        last_check: 2.days.before(Date.current)
      )
    end

    let!(:card2) do
      FactoryBot.create(:card,
        name: 'SMC-KT 0002',
        card_type: 'SMC-KT',
        iccsn: '9980002',
        object_system_version: '4.3.0',
        expiration_date: 1.month.after(Date.current),
        last_check: Time.current
      )
    end

    let!(:card3) do
      FactoryBot.create(:card,
        name: 'SMC-KT 0003',
        card_type: 'SMC-KT',
        iccsn: '9980003',
        object_system_version: '4.3.1',
        operational_state: opsta,
        expiration_date: 1.year.after(Date.current),
        last_check: Time.current,
        card_terminal: ct
      )
    end

    let!(:card4) { FactoryBot.create(:card, deleted_at: 1.minute.before(Time.current)) }
  
    let!(:ack1) do
      FactoryBot.create(:note,
        type: :acknowledge,
        notable_type: 'Card',
        notable_id: card1.id,
      )
    end

    let(:cards) { Card.left_outer_joins(:location, :operational_state).all }

    # check for class methods
    it { expect(Query.respond_to? :new).to be_truthy}

    it "raise an ArgumentError" do
    expect {
      Query.new
    }.to raise_error(ArgumentError)
    end

   # check for instance methods
    describe "instance methods" do
      subject { Query.new(cards) }
      it { expect(subject.respond_to? :all).to be_truthy}
      it { expect(subject.respond_to? :find_each).to be_truthy}
      it { expect(subject.respond_to? :include?).to be_truthy }
    end

   context "with unknown option :fasel" do
      subject { Query.new(cards, {fasel: 'blubb'}) }
      describe "#all" do
        it "does not raise an error" do
          expect { subject.all }.not_to raise_error
        end
        it { expect(subject.all).to be_empty }
      end
    end

    context "with :id" do
      subject { Query.new(cards, {id: card1.to_param}) }
      before(:each) do
        @matching = [card1]
        @nonmatching = [card2, card3]
      end
      it_behaves_like "a card query"
    end # :id

    context "with :name" do
      subject { Query.new(cards, {name: "0001"}) }
      before(:each) do
        @matching = [card1]
        @nonmatching = [card2, card3]
      end
      it_behaves_like "a card query"
    end

    context "with :description" do
      subject { Query.new(cards, {description: "more info"}) }
      before(:each) do
        @matching = [card1]
        @nonmatching = [card2, card3]
      end
      it_behaves_like "a card query"
    end # :description

    context "with :connector_id" do
      let(:conn2) { FactoryBot.create(:connector) }
      let(:ct2)   { FactoryBot.create(:card_terminal, :with_mac, connector: conn2) }
      let!(:card5) { FactoryBot.create(:card, card_terminal: ct2, card_type: 'SMC-B') }
      let!(:card6) { FactoryBot.create(:card, card_type: 'SMC-KT') }
      let!(:slotid6) do
        FactoryBot.create(:card_terminal_slot, 
          card: card6,
          card_terminal: ct,
          slotid: 2
        )
      end
      subject { Query.new(cards, {connector_id: conn.id}) }

      before(:each) do
        card1.contexts << ctx
        @matching = [card1]
        @nonmatching = [card2, card3, card5, card6]
      end
      it_behaves_like "a card query"
    end

    context "with :location_id" do
      subject { Query.new(cards, {location_id: ber.id}) }
      before(:each) do
        @matching = [card1, card3]
        @nonmatching = [card2]
      end
      it_behaves_like "a card query"
    end

    context "with :lid" do
      subject { Query.new(cards, {lid: 'ber'}) }
      before(:each) do
        @matching = [card1, card3]
        @nonmatching = [card2]
        card1.reload; card2.reload; card3.reload
      end
      it_behaves_like "a card query"
    end

    context "with :tag" do
      subject { Query.new(cards, {tag: 'my'}) }
      before(:each) do
        card1.tags << tag
        card1.reload
        @matching = [card1]
        @nonmatching = [card2, card3]
      end
      it_behaves_like "a card query"
    end

    context "with :condition" do
      subject { Query.new(cards, {condition: 2}) }
      before(:each) do
        card1.contexts << ctx
        card1.update_column(:condition, 2)
        @matching = [card1]
        @nonmatching = [card2, card3]
      end
      it_behaves_like "a card query"
    end

    context "with :iccsn" do
      subject { Query.new(cards, {iccsn: "998"}) }
      before(:each) do
        @matching = [card2, card3]
        @nonmatching = [card1]
      end
      it_behaves_like "a card query"
    end

    context "with :object_system_version" do
      subject { Query.new(cards, {object_system_version: "4.3"}) }
      before(:each) do
        @matching = [card2, card3]
        @nonmatching = [card1]
      end
      it_behaves_like "a card query"
    end

    context "with :operational_state" do
      subject { Query.new(cards, {operational_state: "in betrieb"}) }
      before(:each) do
        @matching = [card1, card3]
        @nonmatching = [card2]
      end
      it_behaves_like "a card query"
    end

    context "with operational: true" do
      subject { Query.new(cards, {operational: 'JA'}) }
      before(:each) do
        @matching = [card1, card3]
        @nonmatching = [card2]
      end
      it_behaves_like "a card query"
    end

    context "with operational: false" do
      subject { Query.new(cards, {operational: '0'}) }
      before(:each) do
        @matching = [card2]
        @nonmatching = [card1, card3]
      end
      it_behaves_like "a card query"
    end

    context "with acknowledged: true" do
      subject { Query.new(cards, {acknowledged: 'true'}) }
      before(:each) do
        @matching = [card1]
        @nonmatching = [card2, card3]
        card1.update_acknowledge_id; card1.save
      end
      it_behaves_like "a card query"
    end

    context "with expired: true" do
      subject { Query.new(cards, {expired: 'true'}) }
      before(:each) do
        @matching = [card1]
        @nonmatching = [card2, card3]
      end
      it_behaves_like "a card query"
    end

    context "with expired: false" do
      subject { Query.new(cards, {expired: 'nein'}) }
      before(:each) do
        @matching = [card2, card3]
        @nonmatching = [card1]
      end
      it_behaves_like "a card query"
    end

    context "with deleted: true" do
      subject { Query.new(cards, {deleted: 'ja'}) }
      before(:each) do
        @matching = [card4]
        @nonmatching = [card1, card2, card3]
      end
      it_behaves_like "a card query"
    end

    context "with outdated: true" do
      subject { Query.new(cards, {outdated: 'true'}) }
      before(:each) do
        @matching = [card1]
        @nonmatching = [card2, card3]
      end
      it_behaves_like "a card query"
    end

    describe "#all" do
      context "using :search'" do
        it "searches for name" do
          search = Query.new(cards, {search: '0002'})
          expect(search.all).to contain_exactly(card2)
        end

        it "searches for iccsn" do
          search = Query.new(cards, {search: '998'})
          expect(search.all).to contain_exactly(card2, card3)
        end

      end
    end
  end
end
