require 'rails_helper'

module Cocard
  RSpec.describe ResourceInformation, type: :model do
    let!(:ts) { 1.day.before(Time.current) }
    let(:resource_information_hash) do
      { :status=>{:result=>"OK"},
        :connector=> {
          :vpnti_status=>
            {:connection_status=>"Online", :timestamp=>ts },
          :vpnsis_status=>
            {:connection_status=>"Offline", :timestamp=>ts },
          :operating_state=> {
            :error_state=>
              [{:error_condition=>"EC_No_VPN_TI_Connection",
                :severity=>"Error",
                :type=>"Operation",
                :value=>false,
                :valid_from=>1.month.before(ts)}]}
          }
      }
    end
    subject { Cocard::ResourceInformation.new(resource_information_hash) }

    describe "without argument" do
      it "::new raise an KeyError" do
        expect { Cocard::ResourceInformation.new() }.to raise_error(ArgumentError)
      end
    end

    describe "empty connector_services" do
      it "returns nil" do
        expect { Cocard::ResourceInformation.new(nil) }.not_to raise_error
      end
    end
   
    describe "#connector" do
      it { expect(subject.vpnti_status).to eq(resource_information_hash[:connector][:vpnti_status])}
      it { expect(subject.vpnti_connection_status).to eq("Online")}
      it { expect(subject.vpnti_connection_timestamp).to eq(ts)}
      it { expect(subject.vpnti_online).to be_truthy }
    end

# [{:error_condition=>"EC_No_VPN_TI_Connection",
# :severity=>"Error",
# :type=>"Operation",
# :value=>false,
# :valid_from=>1.month.before(ts)}]}

    describe "#error_states" do
      let(:error_states) { subject.error_states }
      it { expect(error_states).to be_kind_of(Array) }
      it { expect(error_states.count).to eq(1) }
      it { expect(error_states[0].error_condition).to eq('EC_No_VPN_TI_Connection') }
      it { expect(error_states[0].severity).to eq('Error') }
      it { expect(error_states[0].type).to eq('Operation') }
      it { expect(error_states[0].value).to be_falsey }
      it { expect(error_states[0].valid?).to be_falsey }
    end
  end
end
