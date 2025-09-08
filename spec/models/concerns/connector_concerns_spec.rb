require 'rails_helper'

RSpec.describe ConnectorConcerns, type: :model do
  # 
  # connector
  # 
  let(:connector_yml) do
    File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector_services.yaml')
  end   

  let(:connector) do
    FactoryBot.create(:connector,
      ip: ENV['SDS_IP'],
      connector_services: YAML.load_file(connector_yml),
      vpnti_online: true
    )
  end

  describe "with a real connector" do
    describe "#rebootable?" do
      it { expect(connector.rebootable?).to be_truthy }
    end
  end

  describe "with other connector" do
    let(:connector) { FactoryBot.create(:connector) }
    describe "#rebootable?" do
      it { expect(connector.rebootable?).to be_falsey }
    end
  end

  describe "#sds_port" do
    it { expect(connector.sds_port).to eq(80) }
  end

  describe "#soap_port" do
    it { expect(connector.soap_port).to eq(80) }
  end

  describe "#rebooted?" do
    it "no if rebooted_at.nil?" do
      expect(connector).to receive(:rebooted_at).and_return(nil)
      expect(connector.rebooted?).to be_falsey
    end

    it "current rebooted_at" do
      expect(connector).to receive(:rebooted_at).at_least(:once).and_return(Time.current)
      expect(connector.rebooted?).to be_truthy
    end

    it "old rebooted_at" do
      connector.update(rebooted_at: 1.hour.before(Time.current))
      connector.reload
      expect(connector.rebooted?).to be_falsey
      connector.reload
      expect(connector.rebooted_at).to be_nil
    end
  end

  describe "#reboot_active?" do
    it "no if rebooted_at.nil?" do
      expect(connector).to receive(:rebooted_at).and_return(nil)
      expect(connector.reboot_active?).to be_falsey
    end

    it "current rebooted_at" do
      expect(connector).to receive(:rebooted_at).at_least(:once).and_return(Time.current)
      expect(connector.reboot_active?).to be_truthy
    end

    it "old rebooted_at" do
      connector.update(rebooted_at: 2.minutes.before(Time.current))
      connector.reload
      expect(connector.reboot_active?).to be_falsey
    end
  end

  describe "#use_ticlient?" do
    describe "with enable_ticlient disabled" do
      it "returns false" do
        expect(Cocard).to receive(:enable_ticlient).and_return(false)
        expect(connector.use_ticlient?).to be_falsey
      end
    end

    describe "with enable_ticlient enabled" do
      before(:each) do
        expect(Cocard).to receive(:enable_ticlient).and_return(true)
      end

      describe "with identification == KOKOSNUSS" do
        before(:each) do
          expect(connector).to receive(:identification).and_return("KOKOSNUSS")
        end
        it "returns false" do
          expect(connector.use_ticlient?).to be_falsey
        end
      end

      describe "with identification == RISEG-RHSK" do
        before(:each) do
          expect(connector).to receive(:identification).and_return("RISEG-RHSK")
        end
        it "returns false" do
          expect(connector.use_ticlient?).to be_truthy
        end
      end
    end
  end
end
