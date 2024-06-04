require 'rails_helper'

module Cocard
  RSpec.describe ErrorState, type: :model do
    let!(:ts) { 1.day.before(Time.current) }
    let(:error_state_hash) do
      { :error_condition=>"EC_CRL_Expiring",
        :severity=>"Warning",
        :type=>"Security",
        :value=>true,
        :valid_from=>ts
      }
    end

    subject { Cocard::ErrorState.new(error_state_hash) }

    describe "without argument" do
      it "::new raise an KeyError" do
        expect { Cocard::ErrorState.new() }.to raise_error(ArgumentError)
      end
    end

    describe "empty connector_services" do
      it "returns nil" do
        expect { Cocard::ErrorState.new(nil) }.not_to raise_error
      end
    end
   
    describe "#connector" do
      it { expect(subject.error_condition).to eq('EC_CRL_Expiring')}
      it { expect(subject.severity).to eq('Warning')}
      it { expect(subject.type).to eq('Security')}
      it { expect(subject.value).to be_truthy }
      it { expect(subject.valid_from).to eq(ts)}
      it { expect(subject.valid?).to be_truthy }
    end
  end
end
