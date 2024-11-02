require 'rails_helper'

RSpec.describe TI::GetSituationPictureJob, type: :job do
  let(:connector) { FactoryBot.create(:connector) }
  describe '#perform_later' do
    it 'matches with enqueued job without args' do
      expect do
        TI::GetSituationPictureJob.perform_later
      end.to have_enqueued_job(TI::GetSituationPictureJob)
    end

    it 'matches with enqueued job with connector' do
      expect do
        TI::GetSituationPictureJob.perform_later(connector: connector)
      end.to have_enqueued_job(TI::GetSituationPictureJob)
    end
  end
end
