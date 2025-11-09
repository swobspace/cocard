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

    let(:json_token) do
      '{
        "access_token": "eyJraWQiOiJkZGUyMDZiYi1lMDgz",
        "scope": "API",
        "token_type": "Bearer",
        "expires_in": 299
      }'
    end

    subject { RISE::TIClient::System.new(ti_client: tic) }

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(RISE::TIClient::System) }
      it { expect(subject.respond_to?(:ti_client)).to be_truthy }
      it { expect(subject.respond_to?(:get_scheduler)).to be_truthy }
    end

    describe '::new' do
      context 'without argument' do
        it 'raises a KeyError' do
          expect do
            RISE::TIClient::System.new()
          end.to raise_error(KeyError)
        end
      end
    end

    describe '#get_scheduler' do
      let(:scheduler_body) do
        json =<<~EOFS
          {
            "state": "RUNNING"
          }
        EOFS
      end
      let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
      let(:conn)   { Faraday.new { |b| b.adapter(:test, stubs) } }
      before(:each) do
        allow(Faraday).to receive(:new).and_return(conn)
        expect(subject).to receive(:api_token).at_least(:once)
                                              .and_return('eyJraWQiOiJkZGUyMDZiYi1lMDgz')
      end

      after(:each) do
        Faraday.default_connection = nil
      end

      it "success: get scheduler status " do
        stubs.get('/api/v1/manager/konnektor/default/task-scheduler') do
          [
            200, 
            {'Content-Type': 'application/json;charset=UTF-8'},
            scheduler_body
          ]
        end

        called_back = false 
        subject.get_scheduler do |result|
          result.on_success do |message, value|
            called_back = :success
            expect(value).to include(JSON.parse(scheduler_body))
          end
          result.on_failure do |message|
            called_back = :failure
          end
        end
        expect(called_back).to eq(:success)
      end

      it "failure: no content" do
        stubs.get('/api/v1/manager/konnektor/default/task-scheduler') do
          [
            401, 
            {'Content-Type': 'application/json;charset=UTF-8'},
            ''
          ]
        end

        called_back = false 
        subject.get_scheduler do |result|
          result.on_success do |message, value|
            called_back = :success
          end
          result.on_failure do |message|
            called_back = :failure
          end
        end
        expect(called_back).to eq(:failure)
      end
    end
  end
end
