require 'rails_helper'

module VZD
  RSpec.describe Query, vzd: true do
    let(:conn) do
      FactoryBot.create(:connector,
        ip: ENV['CONN_IP'],
        use_tls: ENV['USE_TLS'] || false,
        authentication: ENV['AUTHENTICATION'] || 'noauth',
        auth_user: ENV['AUTH_USER'],
        auth_password: ENV['AUTH_PASSWORD'],
        sds_url: ENV['SDS_URL']
      )
    end

    let(:clientcert) do
      FactoryBot.create(:client_certificate,
        name: 'myname',
        cert: File.read(ENV['CLIENT_CERT_FILE']),
        pkey: File.read(ENV['CLIENT_PKEY_FILE']),
        passphrase: ENV['CLIENT_CERT_PASSPHRASE']
      )
    end

    subject do
      Query.new(connector: conn, client_certificate: clientcert, search_options: filter)
    end

    # check for class methods
    it { expect(Query.respond_to? :new).to be_truthy}

    it "raise an ArgumentError" do
    expect {
      Query.new
    }.to raise_error(ArgumentError)
    end

   # check for instance methods
    describe "instance methods" do
      let(:filter) {{sn: 'Nonexistent'}}
      it { expect(subject.respond_to? :all).to be_truthy}
      it { expect(subject.respond_to? :first).to be_truthy}
    end

   context "with unknown option :fasel" do
      let(:filter) {{fasel: 'blubb'}}
      describe "#all" do
        it "does not raise an error" do
          expect { subject.all }.to raise_error(RuntimeError)
        end
      end
    end

    context "with :telematikid" do
      let(:filter) {{telematikid: '5-2-260710873'}}
      it { expect(subject.first.telematikid).to eq('5-2-260710873') }
      it { expect(subject.first.displayname).to eq('Verbund-Krankenhaus Linz-Remagen') }
    end

    context "with :mail" do
      let(:filter) {{mail: 'intensiv.wnd@marienhaus'}}
      it { expect(subject.first.mails).to include('intensiv.wnd@marienhaus.kim.telematik') }
      it { expect(subject.first.displayname).to eq('Marienhaus Klinikum St. Wendel-Ottweiler') }
    end

    context "with :displayname" do
      let(:filter) {{displayname: 'Marienhaus Klinikum St. Wendel'}}
      it { expect(subject.first.mails).to include('intensiv.wnd@marienhaus.kim.telematik') }
      it { expect(subject.first.displayname).to eq('Marienhaus Klinikum St. Wendel-Ottweiler') }
    end

  end
end
