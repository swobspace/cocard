require 'rails_helper'

RSpec.describe CleanupExpiredAcknowledgesJob, type: :job do
  let(:connector) { FactoryBot.create(:connector) }

  describe '#perform_later' do
    it 'matches with enqueued job without args' do
      expect do
        CleanupExpiredAcknowledgesJob.perform_later
      end.to have_enqueued_job(CleanupExpiredAcknowledgesJob)
    end
  end
end
