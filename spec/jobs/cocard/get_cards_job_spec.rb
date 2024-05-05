require 'rails_helper'

RSpec.describe Cocard::GetCardsJob, type: :job do
  let(:connector) { FactoryBot.create(:connector) }
  describe '#perform_later' do
    it 'matches with enqueued job without args' do
      expect do
        Cocard::GetCardsJob.perform_later
      end.to have_enqueued_job(Cocard::GetCardsJob)
    end

    it 'matches with enqueued job with connector' do
      expect do
        Cocard::GetCardsJob.perform_later(connector: connector)
      end.to have_enqueued_job(Cocard::GetCardsJob).with(connector: connector)
    end
  end
end
