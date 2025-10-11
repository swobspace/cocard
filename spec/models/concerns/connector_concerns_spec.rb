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

  describe "#rmi" do
    it { expect(connector.rmi).to be_kind_of Connectors::RMI }
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

  describe "can_authenticate?" do
    describe "with authentication == :noauth" do
      before(:each) do
        expect(connector).to receive(:authentication).and_return('noauth')
      end
      it { expect(connector.can_authenticate?('iMedOne')).to be_truthy }
      it { expect(connector.can_authenticate?(nil)).to be_truthy }
    end

    describe "with authentication == :basicauth" do
      before(:each) do
        expect(connector).to receive(:authentication).and_return('basicauth')
      end

      describe "auth_user/auth_password NOT set" do
        it { expect(connector.can_authenticate?('iMedOne')).to be_falsey }
        it { expect(connector.can_authenticate?(nil)).to be_falsey }
      end

      describe "auth_user/auth_password set" do
        before(:each) do
          expect(connector).to receive(:auth_user).and_return('dummy')
          expect(connector).to receive(:auth_password).and_return('geheim')
        end
        it { expect(connector.can_authenticate?('iMedOne')).to be_truthy }
        it { expect(connector.can_authenticate?(nil)).to be_truthy }
      end
    end

    describe "with authentication == :clientcert" do
      before(:each) do
        expect(connector).to receive(:authentication).and_return('clientcert')
      end

      describe "no client cert available" do
        it { expect(connector.can_authenticate?('iMedOne')).to be_falsey }
        it { expect(connector.can_authenticate?(nil)).to be_falsey }
      end

      describe "with client_cert intern available" do
        let(:cert) { FactoryBot.create(:client_certificate) }
        before(:each) do
          connector.client_certificates << cert
          connector.reload
        end
        it { expect(connector.can_authenticate?('intern')).to be_truthy }
        it { expect(connector.can_authenticate?('jibbetnich')).to be_falsey }
      end
    end

  end

end
