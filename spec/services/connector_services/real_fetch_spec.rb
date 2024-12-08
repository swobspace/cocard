require 'rails_helper'

# real fetch with --tag soap

module ConnectorServices
  RSpec.describe Fetch, :soap => true do
    let(:connector) do
      FactoryBot.create(:connector,
        ip: ENV['SDS_IP'],
        use_tls: ENV['USE_TLS'] || false,
        authentication: ENV['AUTHENTICATION'] || 'noauth',
        auth_user: ENV['AUTH_USER'],
        auth_password: ENV['AUTH_PASSWORD'],
        sds_url: ENV['SDS_URL']
      )
    end
    subject { ConnectorServices::Fetch.new( connector: connector) }

    describe '#call' do
      describe 'with status 200' do
        let(:result) { subject.call }
        # it { puts result.error_messages.inspect }

        it { expect(result.success?).to be_truthy }
        it { expect(result.respond_to?(:error_messages)).to be_truthy }
        it { expect(result.respond_to?(:sds)).to be_truthy }
        it { expect(result.error_messages.present?).to be_falsey }
        it { expect(result.sds).to be_present }
        it { expect(result.sds.keys).to include( "TLSMandatory", "ClientAutMandatory",
                                          "ProductInformation", "ServiceInformation") }
        it 'updates last_check' do
          expect do
            subject.call
          end.to change(connector, :last_check)
        end
      end
    end
  end
end
