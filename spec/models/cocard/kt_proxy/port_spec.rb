require 'rails_helper'

module Cocard
  module KTProxy
    RSpec.describe Port, type: :model do
      subject {Cocard::KTProxy::Port.new(port_range: port_range, used_ports: used_ports) }
      describe "without argument" do
        it "::new raise an KeyError" do
          expect { Cocard::KTProxy::Port.new() }.to raise_error(ArgumentError)
        end
      end

      describe "with free upper ports" do
        let(:used_ports) { [10,20,30,40] }
        let(:port_range) { "10:100" }
        it { expect(subject.next_port).to eq(41) }
        it { expect(subject.first_unused_port).to eq(11) }
      end

      describe "with free ports, but max reached" do
        let(:used_ports) { [10,20,30,40] }
        let(:port_range) { "10:40" }
        it { expect(subject.next_port).to eq(11) }
        it { expect(subject.first_unused_port).to eq(11) }
      end

      describe "with no free ports" do
        let(:used_ports) { [1,2,3,4,5] }
        let(:port_range) { "1:5" }
        it { expect(subject.next_port).to eq(-1) }
        it { expect(subject.first_unused_port).to eq(-1) }
      end

    end
  end
end
