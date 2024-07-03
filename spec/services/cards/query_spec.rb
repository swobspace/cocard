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
    let(:ber) { FactoryBot.create(:location, lid: 'BER') }
    let(:conn) { FactoryBot.create(:connector) }
    let(:ct)  { FactoryBot.create(:card_terminal, :with_mac, connector: conn) }
    let(:opsta) { FactoryBot.create(:operational_state, name: 'in Betrieb', operational: true) }
    let!(:card1) do
      FactoryBot.create(:card,
        name: 'SMC-B 0001',
        description: "some more infos",
        location: ber,
        iccsn: '9990001',
        operational_state: opsta,
        card_terminal: ct,
        expiration_date: 1.day.before(Date.current)
      )
    end

    let!(:card2) do
      FactoryBot.create(:card,
        name: 'SMC-KT 0002',
        iccsn: '9980002',
      )
    end

    let!(:card3) do
      FactoryBot.create(:card,
        name: 'SMC-KT 0003',
        iccsn: '9980003',
        operational_state: opsta
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
        it "raises a argument error" do
          expect { subject.all }.to raise_error(ArgumentError)
        end
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

    context "with :lid" do
      subject { Query.new(cards, {lid: 'ber'}) }
      before(:each) do
        @matching = [card1]
        @nonmatching = [card2, card3]
      end
      it_behaves_like "a card query"
    end

    context "with :condition" do
      subject { Query.new(cards, {condition: 2}) }
      before(:each) do
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

    context "with :operational_state" do
      subject { Query.new(cards, {operational_state: "in betrieb"}) }
      before(:each) do
        @matching = [card1, card3]
        @nonmatching = [card2]
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
