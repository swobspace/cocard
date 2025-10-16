require 'rails_helper'

module KTProxies
  RSpec.shared_examples "a kt_proxy query" do
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
    let(:tic01)  { FactoryBot.create(:ti_client) }
    let(:tic02)  { FactoryBot.create(:ti_client) }
    let(:ct)  { FactoryBot.create(:card_terminal, :with_mac) }
    let!(:kt_proxy1) do
      FactoryBot.create(:kt_proxy,
        card_terminal: ct,
        uuid: "12345",
        name: "Name1",
        wireguard_ip: '198.51.100.1',
        incoming_ip: "192.0.2.1",
        incoming_port: 8101,
        outgoing_ip: "192.0.2.2",
        outgoing_port: 8101,
        card_terminal_ip: "192.168.1.1",
        card_terminal_port: 4742,
        ti_client_id: tic01.id
      )
    end

    let!(:kt_proxy2) do
      FactoryBot.create(:kt_proxy,
        uuid: "23456",
        name: "Name2",
        wireguard_ip: '198.51.100.1',
        incoming_ip: "192.0.2.1",
        incoming_port: 8102,
        outgoing_ip: "192.0.2.2",
        outgoing_port: 8102,
        card_terminal_ip: "192.168.1.2",
        card_terminal_port: 4742,
        ti_client_id: tic02.id
      )
    end

    let!(:kt_proxy3) do
      FactoryBot.create(:kt_proxy,
        uuid: "34567",
        name: "Name3",
        wireguard_ip: '198.51.100.1',
        incoming_ip: "192.0.2.1",
        incoming_port: 8103,
        outgoing_ip: "192.0.2.2",
        outgoing_port: 8103,
        card_terminal_ip: "192.168.1.3",
        card_terminal_port: 4742,
        ti_client_id: tic02.id
      )
    end

    let(:kt_proxys) { KTProxy.all }

    # check for class methods
    it { expect(Query.respond_to? :new).to be_truthy}

    it "raise an ArgumentError" do
    expect {
      Query.new
    }.to raise_error(ArgumentError)
    end

   # check for instance methods
    describe "instance methods" do
      subject { Query.new(kt_proxys) }
      it { expect(subject.respond_to? :all).to be_truthy}
      it { expect(subject.respond_to? :find_each).to be_truthy}
      it { expect(subject.respond_to? :include?).to be_truthy }
    end

   context "with unknown option :fasel" do
      subject { Query.new(kt_proxys, {fasel: 'blubb'}) }
      describe "#all" do
        it "does not raise an error" do
          expect { subject.all }.not_to raise_error
        end
        it { expect(subject.all).to be_empty }
      end
    end

    context "with :id" do
      subject { Query.new(kt_proxys, {id: kt_proxy1.to_param}) }
      before(:each) do
        @matching = [kt_proxy1]
        @nonmatching = [kt_proxy2, kt_proxy3]
      end
      it_behaves_like "a kt_proxy query"
    end

    context "with :card_terminal_id" do
      subject { Query.new(kt_proxys, {card_terminal_id: ct.id.to_param}) }
      before(:each) do
        @matching = [kt_proxy1]
        @nonmatching = [kt_proxy2, kt_proxy3]
      end
      it_behaves_like "a kt_proxy query"
    end

    context "with :name" do
      subject { Query.new(kt_proxys, {name: "name1"}) }
      before(:each) do
        @matching = [kt_proxy1]
        @nonmatching = [kt_proxy2, kt_proxy3]
      end
      it_behaves_like "a kt_proxy query"
    end

    context "with :port" do
      subject { Query.new(kt_proxys, {port: 8102}) }
      before(:each) do
        @matching = [kt_proxy2]
        @nonmatching = [kt_proxy1, kt_proxy3]
      end
      it_behaves_like "a kt_proxy query"
    end

    describe "#all" do
      context "using :search'" do
        it "searches for name" do
          search = Query.new(kt_proxys, {search: 8103})
          expect(search.all).to contain_exactly(kt_proxy3)
        end

        it "searches for name" do
          search = Query.new(kt_proxys, {search: 'name'})
          expect(search.all).to contain_exactly(kt_proxy1, kt_proxy2, kt_proxy3)
        end

      end
    end
  end
end
