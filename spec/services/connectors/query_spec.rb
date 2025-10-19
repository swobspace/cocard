require 'rails_helper'

module Connectors
  RSpec.shared_examples "a connectors query" do
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
    let!(:conn1) do
      FactoryBot.create(:connector,
        name: 'TIK-AXC-17',
        short_name: 'K17',
        description: "some more infos",
        ip: '127.51.100.17',
        firmware_version: '5.3.4',
        locations: [ber]
      )
    end

    let!(:conn2) do
      FactoryBot.create(:connector,
        name: 'TIK-CWZ-04',
        short_name: 'K04',
        ip: '127.203.113.4',
        admin_url: 'https://127.192.2.4:9443',
        sds_url: 'http://127.192.2.4/connector.sds',
        manual_update: true,
        firmware_version: '4.9.3',
      )
    end

    let!(:conn3) do
      FactoryBot.create(:connector,
        name: 'TIK-CWZ-05',
        short_name: 'K05',
        ip: '127.50.100.5',
        manual_update: true,
        firmware_version: '4.9.3',
      )
    end

    let(:connectors) { Connector.all.with_rich_text_description }

    # check for class methods
    it { expect(Query.respond_to? :new).to be_truthy}

    it "raise an ArgumentError" do
    expect {
      Query.new
    }.to raise_error(ArgumentError)
    end

   # check for instance methods
    describe "instance methods" do
      subject { Query.new(connectors) }
      it { expect(subject.respond_to? :all).to be_truthy}
      it { expect(subject.respond_to? :find_each).to be_truthy}
      it { expect(subject.respond_to? :include?).to be_truthy }
    end

   context "with unknown option :fasel" do
      subject { Query.new(connectors, {fasel: 'blubb'}) }
      describe "#all" do
        it "does not raise an error" do
          expect { subject.all }.not_to raise_error
        end
        it { expect(subject.all).to be_empty }
      end
    end

    context "with :name" do
      subject { Query.new(connectors, {name: 'cwz'}) }
      before(:each) do
        @matching = [conn2, conn3]
        @nonmatching = [conn1]
      end
      it_behaves_like "a connectors query"
    end # :name

    context "with :short_name" do
      subject { Query.new(connectors, {short_name: 'k04'}) }
      before(:each) do
        @matching = [conn2]
        @nonmatching = [conn1, conn3]
      end
      it_behaves_like "a connectors query"
    end # :short_name

    context "with :id" do
      subject { Query.new(connectors, {id: conn1.to_param}) }
      before(:each) do
        @matching = [conn1]
        @nonmatching = [conn2, conn3]
      end
      it_behaves_like "a connectors query"
    end # :id

    context "with :description" do
      subject { Query.new(connectors, {description: "more info"}) }
      before(:each) do
        @matching = [conn1]
        @nonmatching = [conn2, conn3]
      end
      it_behaves_like "a connectors query"
    end # :description

    context "with :lid" do
      subject { Query.new(connectors, {lid: 'ber'}) }
      before(:each) do
        @matching = [conn1]
        @nonmatching = [conn2, conn3]
      end
      it_behaves_like "a connectors query"
    end

    context "with :tag" do
      subject { Query.new(connectors, {tag: 'my'}) }
      before(:each) do
        conn1.tags << tag
        conn1.reload
        @matching = [conn1]
        @nonmatching = [conn2, conn3]
      end
      it_behaves_like "a connectors query"
    end

    context "with :ip" do
      subject { Query.new(connectors, {ip: '127.203.113.'}) }
      before(:each) do
        @matching = [conn2]
        @nonmatching = [conn1, conn3]
      end
      it_behaves_like "a connectors query"
    end

    context "with :admin_url" do
      subject { Query.new(connectors, {admin_url: '127.192.2.4'}) }
      before(:each) do
        @matching = [conn2]
        @nonmatching = [conn1, conn3]
      end
      it_behaves_like "a connectors query"
    end

    context "with :sds_url" do
      subject { Query.new(connectors, {sds_url: '127.192.2.4'}) }
      before(:each) do
        @matching = [conn2]
        @nonmatching = [conn1, conn3]
      end
      it_behaves_like "a connectors query"
    end

    context "with :condition" do
      subject { Query.new(connectors, {condition: 3}) }
      before(:each) do
        @matching = [conn1]
        @nonmatching = [conn2, conn3]
      end
      it_behaves_like "a connectors query"
    end

    context "with :manual_update" do
      subject { Query.new(connectors, {manual_update: true}) }
      before(:each) do
        @matching = [conn2, conn3]
        @nonmatching = [conn1]
      end
      it_behaves_like "a connectors query"
    end

    context "with :vpnti_online" do
      subject { Query.new(connectors, {vpnti_online: false}) }
      before(:each) do
        @matching = [conn1, conn2, conn3]
        @nonmatching = []
      end
      it_behaves_like "a connectors query"
    end

    context "with :soap_request_success" do
      subject { Query.new(connectors, {soap_request_success: false}) }
      before(:each) do
        @matching = [conn1, conn2, conn3]
        @nonmatching = []
      end
      it_behaves_like "a connectors query"
    end

    context "with :firmware_version" do
      subject { Query.new(connectors, {firmware_version: '4.9'}) }
      before(:each) do
        @matching = [conn2, conn3]
        @nonmatching = [conn1]
      end
      it_behaves_like "a connectors query"
    end

    describe "#all" do
      context "using :search'" do
        it "searches for name" do
          search = Query.new(connectors, {search: 'cwz'})
          expect(search.all).to contain_exactly(conn2, conn3)
        end

        it "searches for admin_url" do
          search = Query.new(connectors, {search: '127.192.2.'})
          expect(search.all).to contain_exactly(conn2)
        end

        it "searches for ip" do
          search = Query.new(connectors, {search: '127.203.113.'})
          expect(search.all).to contain_exactly(conn2)
        end

        it "searches for firmware_version" do
          search = Query.new(connectors, {search: '4.9.'})
          expect(search.all).to contain_exactly(conn2, conn3)
        end


      end
    end
  end
end
