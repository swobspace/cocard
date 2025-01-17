require 'rails_helper'

RSpec.describe Cards::VerifyAllPinsJob, type: :job do
  describe '#perform_later' do
    it 'matches with enqueued job without args' do
      expect do
        Cards::VerifyAllPinsJob.perform_later
      end.to have_enqueued_job(Cards::VerifyAllPinsJob)
    end
  end
end
