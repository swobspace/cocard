require 'rails_helper'

RSpec.describe Connectors::RebootJob, type: :job do
  let(:connector) { FactoryBot.create(:connector) }
  describe '#perform_later' do
    it 'matches with enqueued job without args' do
      expect do
        Connectors::RebootJob.perform_later
      end.to have_enqueued_job(Connectors::RebootJob)
    end

    it 'matches with enqueued job with connector' do
      expect do
        Connectors::RebootJob.perform_later(connector: connector)
      end.to have_enqueued_job(Connectors::RebootJob).with(connector: connector)
    end
  end

end
