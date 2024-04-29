require 'rails_helper'

RSpec.describe Cocard::GetResourceInformationJob, type: :job do
  let(:connector) { FactoryBot.create(:connector) }
  describe '#perform_later' do
    it 'matches with enqueued job without args' do
      expect do
        Cocard::GetResourceInformationJob.perform_later
      end.to have_enqueued_job(Cocard::GetResourceInformationJob)
    end

    it 'matches with enqueued job with connector' do
      expect do
        Cocard::GetResourceInformationJob.perform_later(connector: connector)
      end.to have_enqueued_job(Cocard::GetResourceInformationJob).with(connector: connector)
    end
  end
end
