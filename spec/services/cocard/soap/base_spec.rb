require 'rails_helper'

module Cocard::SOAP
  RSpec.describe Base do
    let(:connector) do
      FactoryBot.create(:connector,
        ip: ENV['SDS_IP'],
      )
    end

    it "raise an NotImplementedError" do
      expect {
        Cocard::SOAP::Base.new(
          connector: connector,
          mandant: 'Ein1',
          client_system_id: 'Cocard',
          workplace_id: 'Konnektor'
        )
      }.to raise_error NotImplementedError
    end
  end
end
