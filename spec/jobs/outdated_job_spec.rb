require 'rails_helper'

RSpec.describe OutdatedJob, type: :job do
  describe '#perform_later' do
    it 'matches with enqueued job without args' do
      expect do
        OutdatedJob.perform_later
      end.to have_enqueued_job(OutdatedJob)
    end
  end
end
