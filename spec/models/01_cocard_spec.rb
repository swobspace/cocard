# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cocard, type: :model do
  context ' with empty Settings' do
    before(:each) do
      allow(Cocard::CONFIG).to receive(:[]).with('ldap_options').and_return(nil)
      allow(Cocard::CONFIG).to receive(:[]).with('enable_ldap_authentication').and_return(nil)
    end
    it { expect(Cocard.enable_ldap_authentication).to be_falsey }
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
