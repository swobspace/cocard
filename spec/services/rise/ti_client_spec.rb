# frozen_string_literal: true

require 'rails_helper'
module RISE
  RSpec.describe TIClient do
    let(:tic) do
      FactoryBot.create(:ti_client,
        name: "TIC01",
        url: ENV['TIC_URL']
      )
    end

    subject { RISE::TIClient.new(ti_client: tic) }

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(RISE::TIClient) }
      it { expect(subject.respond_to?(:ti_client)).to be_truthy }
      it { expect(subject.respond_to?(:api_token)).to be_truthy }
      it { expect(subject.respond_to?(:authorization)).to be_truthy }
      it { expect(subject.respond_to?(:authenticate)).to be_truthy }
    end

    describe '::new' do
      context 'without argument' do
        it 'raises a KeyError' do
          expect do
            RISE::TIClient::Token.new()
          end.to raise_error(ArgumentError)
        end
      end

    end
  end
end

