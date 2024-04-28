require 'rails_helper'

RSpec.describe ConnectorServices::FetchJob, type: :job do
  let(:connector) { FactoryBot.create(:connector) }
  describe '#perform_later' do
    it 'matches with enqueued job without args' do
      expect do
        ConnectorServices::FetchJob.perform_later
      end.to have_enqueued_job(ConnectorServices::FetchJob)
    end

    it 'matches with enqueued job with connector' do
      expect do
        ConnectorServices::FetchJob.perform_later(connector: connector)
      end.to have_enqueued_job(ConnectorServices::FetchJob).with(connector: connector)
    end
  end
end
