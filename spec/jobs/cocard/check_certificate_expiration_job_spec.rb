require 'rails_helper'

RSpec.describe Cocard::CheckCertificateExpirationJob, type: :job do
  let(:connector) { FactoryBot.create(:connector) }
  let(:context)   { FactoryBot.create(:context) }
  let!(:connector_context) do
    FactoryBot.create(:connector_context,
      connector: connector,
      context: context,
    )
  end
  describe '#perform_later' do
    it 'matches with enqueued job without args' do
      expect do
        Cocard::CheckCertificateExpirationJob.perform_later
      end.to have_enqueued_job(Cocard::CheckCertificateExpirationJob)
    end

    it 'matches with enqueued job with connector' do
      expect do
        Cocard::CheckCertificateExpirationJob.perform_later(connector: connector)
      end.to have_enqueued_job(Cocard::CheckCertificateExpirationJob).with(connector: connector)
    end

    describe '#perform_now' do
      let(:check_instance) { instance_double(Cocard::CheckCertificateExpiration) }
      let(:check_class) do
         class_double(Cocard::CheckCertificateExpiration).as_stubbed_const
      end
      let(:result) { Struct.new(:success?, :error_messages, :cards) }

      before(:each) do
        allow(check_class).to receive(:new).and_return(check_instance)
      end

      it 'with success = false' do
        expect(check_instance).to receive(:call).and_return(result.new(false, ["some errors"], nil))
        expect(Rails.logger).to receive(:warn).at_least(:once)
        Cocard::CheckCertificateExpirationJob.perform_now(connector: connector)
      end

      it 'with success = true' do
        expect(check_instance).to receive(:call).and_return(result.new(true, [], nil))
        expect(Rails.logger).to receive(:debug).at_least(:once)
        Cocard::CheckCertificateExpirationJob.perform_now(connector: connector)
      end
    end
  end
end
