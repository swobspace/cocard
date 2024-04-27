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
  end
end
