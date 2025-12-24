# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cocard, type: :model do
  describe ' with empty Settings' do
    before(:each) do
      allow(Cocard::CONFIG).to receive(:[]).with('ldap_options').and_return(nil)
      allow(Cocard::CONFIG).to receive(:[]).with('enable_ldap_authentication').and_return(nil)
      allow(Cocard::CONFIG).to receive(:[]).with('enable_ticlient').and_return(nil)
      allow(Cocard::CONFIG).to receive(:[]).with('ktproxy_defaults').and_return(nil)
      allow(Cocard::CONFIG).to receive(:[]).with('ktproxy_equal_ports').and_return(nil)
      allow(Cocard::CONFIG).to receive(:[]).with('card_terminal_defaults').and_return({})
      allow(Cocard::CONFIG).to receive(:[]).with('mail_from').and_return(nil)
      allow(Cocard::CONFIG).to receive(:[]).with('mail_to').and_return(nil)
      allow(Cocard::CONFIG).to receive(:[]).with('smtp_settings').and_return(nil)
      allow(ENV).to receive(:[]).with('CRON_REBOOT_CONNECTORS').and_return(nil)
      allow(ENV).to receive(:[]).with('AUTO_REBOOT_CONNECTORS_NOTE').and_return(nil)
    end
    it { expect(Cocard.enable_ldap_authentication).to be_falsey }
    it { expect(Cocard.enable_ticlient).to be_falsey }
    it { expect(Cocard.ktproxy_defaults).to eq({}) }
    it { expect(Cocard.ktproxy_equal_ports).to be_falsey }
    it { expect(Cocard.cron_reboot_connectors).to eq('5 1 * * 1') }
    it { expect(Cocard.auto_reboot_connectors_note).to be_falsey }
    it { expect(Cocard.card_terminal_defaults).to eq({}) }
    it { expect(Cocard.mail_from).to eq('root') }
    it { expect(Cocard.mail_to).to eq([]) }
    it { expect(Cocard.smtp_settings).to eq(nil) }
    it { expect(Cocard.use_mail?).to be_falsey }
  end

  describe "with settings" do
    let(:smtp_settings) do
      { 'address' => 'somehost', 'port' => 25 }
    end
    let(:ct_defaults) {{
      "ntp_server"  => "198.51.100.2",
      "ntp_enabled" => true,
      "tftp_server" => "127.0.1.2",
      "tftp_file"   => "firmware.dat"
    }}
    it "uses ENV if valid?" do
      allow(ENV).to receive(:[]).with('CRON_REBOOT_CONNECTORS').and_return('1 2 3 4 5')
      allow(ENV).to receive(:[]).with('AUTO_REBOOT_CONNECTORS_NOTE').and_return('yes')
      expect(Cocard.cron_reboot_connectors).to eq('1 2 3 4 5')
      expect(Cocard.auto_reboot_connectors_note).to be_truthy
    end

    it "in CONFIG" do
      allow(Cocard::CONFIG).to receive(:[]).with('enable_ticlient').and_return(true)
      allow(Cocard::CONFIG).to receive(:[]).with('ktproxy_defaults').and_return({card_terminal_port: 4742})
      allow(Cocard::CONFIG).to receive(:[]).with('ktproxy_equal_ports').and_return(true)
      allow(Cocard::CONFIG).to receive(:[]).with('card_terminal_defaults').and_return(ct_defaults)
      allow(Cocard::CONFIG).to receive(:[]).with('mail_from').and_return('from@example.org')
      allow(Cocard::CONFIG).to receive(:[]).with('mail_to').and_return(['somebody@example.net'])
      allow(Cocard::CONFIG).to receive(:[]).with('smtp_settings').and_return(smtp_settings)

      expect(Cocard.enable_ticlient).to be_truthy
      expect(Cocard.ktproxy_defaults).to include(card_terminal_port: 4742)
      expect(Cocard.ktproxy_equal_ports).to be_truthy
      expect(Cocard.card_terminal_defaults).to include(
        ntp_server: '198.51.100.2',
        ntp_enabled: true,
        tftp_server: '127.0.1.2',
        tftp_file: 'firmware.dat'
      ) 
      expect(Cocard.mail_from).to eq('from@example.org')
      expect(Cocard.mail_to).to eq(['somebody@example.net'])
      expect(Cocard.smtp_settings).to include(address: 'somehost', port: 25)
      expect(Cocard.use_mail?).to be_truthy
    end

    it "uses default if ENV not valid" do
      allow(ENV).to receive(:[]).with('CRON_REBOOT_CONNECTORS').and_return('1 2 3')
      allow(ENV).to receive(:[]).with('AUTO_REBOOT_CONNECTORS_NOTE').and_return('no')
      expect(Cocard.cron_reboot_connectors).to eq('5 1 * * 1')
      expect(Cocard.auto_reboot_connectors_note).to be_falsey
    end
  end

  describe '::ldap_options' do
    context ' with existing Settings' do
      let(:ldap_options) do
        {
          'host' => '192.0.2.71',
          'port' => 3268,
          'base' => 'dc=example,dc=com',
          'auth' => {
            'method' => :simple,
            'username' => 'myldapuser',
            'password' => 'myldappasswd'
          }
        }
      end
      let(:ldap_options_ary) do
        [{
          'host' => '192.0.2.71',
          'port' => 3268,
          'base' => 'dc=example,dc=com',
          'auth' => {
            'method' => :simple,
            'username' => 'myldapuser',
            'password' => 'myldappasswd'
          }
        }]
      end
      let(:ldap_options_sym) do
        [{
          host: '192.0.2.71',
          port: 3268,
          base: 'dc=example,dc=com',
          auth: {
            method: :simple,
            username: 'myldapuser',
            password: 'myldappasswd'
          }
        }]
      end

      it 'returns symbolized keys from Hash' do
        allow(Cocard::CONFIG).to receive(:[]).with('ldap_options')
                                            .and_return(ldap_options)
        expect(Cocard.ldap_options).to eq(ldap_options_sym)
      end

      it 'returns symbolized keys from Array of Hashes' do
        allow(Cocard::CONFIG).to receive(:[]).with('ldap_options')
                                            .and_return(ldap_options_ary)
        expect(Cocard.ldap_options).to eq(ldap_options_sym)
      end


      it "set enable ldap auth to false" do
        allow(Cocard::CONFIG).to receive(:[]).with('enable_ldap_authentication')
                                            .and_return(false)
        allow(Cocard::CONFIG).to receive(:[]).with('ldap_options')
                                            .and_return(ldap_options)
        expect(Cocard.enable_ldap_authentication).to be_falsey
      end

      it "set enable ldap auth to true" do
        allow(Cocard::CONFIG).to receive(:[]).with('enable_ldap_authentication')
                                            .and_return(true)
        allow(Cocard::CONFIG).to receive(:[]).with('ldap_options')
                                            .and_return(ldap_options)
        expect(Cocard.enable_ldap_authentication).to be_truthy
      end
    end
  end
  describe "routes.default_url_options" do
    # Routes default url options has to be set in local configuration file mirco.yml
    it "sets default_url_options" do
      expect(Rails.application.routes.default_url_options).to include(
             host: 'localhost', port: '3000', protocol: 'http')
    end
  end

end
