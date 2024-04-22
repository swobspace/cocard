require 'rails_helper'

module ConnectorServices
  RSpec.describe Fetch do
    Fake = Struct.new(:headers, :success?, :status, :body)
    let(:sds_file) { File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector.sds') }
    let(:sds_string)      { File.read(sds_file) }
    let(:connector) do
      FactoryBot.create(:connector,
        ip: ENV['SDS_IP'],
        sds_url: ENV['SDS_URL']
      )
    end
    subject { ConnectorServices::Fetch.new( connector: connector) }


    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject.respond_to?(:call)).to be_truthy }
    end

    describe '#call' do
      describe 'with status 200' do
        let(:result) { subject.call }
        let(:fake) do
          Fake.new([], true, 200, sds_string)
        end

        before(:each) do
          expect(Faraday).to receive(:get).with(any_args).and_return(fake)
        end

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

        it 'updates last_check' do
          expect do
            subject.call
          end.to change(connector, :last_check_ok)
        end
      end

      describe 'with status 500' do
        let(:result) { subject.call }
        let(:fake) do
          Fake.new(['nonsense'], false, 500, 'no information available')
        end

        before(:each) do
          expect(Faraday).to receive(:get).with(any_args).and_return(fake)
        end

        it { expect(result.success?).to be_falsey }
        it { expect(result.respond_to?(:error_messages)).to be_truthy }
        it { expect(result.respond_to?(:sds)).to be_truthy }
        it { expect(result.error_messages).to include('nonsense', 
                                                      'no information available') }
        it { expect(result.sds).to be_nil }

        it 'updates last_check' do
          expect do
            subject.call
          end.to change(connector, :last_check)
        end

        it 'does not update last_check' do
          expect do
            subject.call
          end.not_to change(connector, :last_check_ok)
        end


      end
    end
  end
end
