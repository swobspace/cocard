require 'rails_helper'

RSpec.describe Connectors::HealthCheckJob, type: :job do
  let(:connector) { FactoryBot.create(:connector) }
  describe '#perform_later' do
    it 'matches with enqueued job without args' do
      expect do
        Connectors::HealthCheckJob.perform_later
      end.to have_enqueued_job(Connectors::HealthCheckJob)
    end

    it 'matches with enqueued job with connector' do
      expect do
        Connectors::HealthCheckJob.perform_later(connector: connector)
      end.to have_enqueued_job(Connectors::HealthCheckJob).with(connector: connector)
    end
  end
end
