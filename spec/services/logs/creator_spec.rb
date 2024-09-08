# frozen_string_literal: true

require 'rails_helper'
module Logs
  RSpec.describe Creator do
    let!(:ts)   { Time.current }
    let(:conn) { FactoryBot.create(:connector) }

    subject do
      Logs::Creator.new(
        loggable: conn,
        action: "GetResource",
        level: "WARN",
        last_seen: ts,
        message: "hier klappt was nicht"
      )
    end

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(Logs::Creator) }
      it { expect(subject.respond_to?(:call)).to be_truthy }
    end

    describe '#new' do
      context 'without params' do
        it 'raises a KeyError' do
          expect do
            Creator.new()
          end.to raise_error(KeyError)
        end
      end
    end

    describe '#call' do
      context 'new log' do
        let(:log) { subject.call; subject.log }
        it 'create a new log entry' do
          expect do
            subject.call
          end.to change(Log, :count).by(1)
          expect(subject.log).to be_kind_of(Log)
        end

        it { expect(log.loggable).to eq(conn) }
        it { expect(log.action).to eq('GetResource') }
        it { expect(log.level).to eq('WARN') }
        it { expect(log.message).to eq('hier klappt was nicht') }
        it { expect(log.last_seen).to eq(ts) }
        it { expect(log.since.to_s).to eq(ts.to_s) }

      end

      it { expect(subject.call).to be_truthy }

      context 'with an existing log' do
        let!(:ack) do
          FactoryBot.create(:note, notable: log, 
            type: Note.types[:acknowledge]
          )
        end
        let!(:oldack) do
          FactoryBot.create(:note, notable: log,
            type: Note.types[:acknowledge],
            valid_until: Date.yesterday
          )
        end

        let!(:log) do
          FactoryBot.create(:log,
            loggable: conn,
            action: "GetResource",
            level: "WARN",
            is_valid: true,
            last_seen: 1.day.before(Time.current),
            message: "hier klappt was nicht",
            since: 1.day.before(ts)
          )
        end
        before(:each) { log.reload }

        it 'does not create a log' do
          expect {
            subject.call
          }.to change(Log, :count).by(0)
          expect(subject.log).to be_kind_of(Log)
          expect(subject.log).to eq(log)
        end

        it 'updates acknowledge' do
          log.update(acknowledge_id: oldack.id)
          log.reload
          expect(log.acknowledge_id).to eq(oldack.id)
          subject.call(false)
          log.reload
          expect(log.acknowledge_id).to eq(ack.id)
        end

        it 'deletes log with call(true)' do
          expect {
            subject.call(true)
          }.not_to change(Log, :count)
        end

        it 'marks entry as invalid' do
          subject.call(true)
          log.reload
          expect(log.is_valid).to be_falsey
        end

        it 'terminates all open acknowledges' do
          expect(ack.valid_until).to be_nil
          subject.call(true)
          ack.reload
          expect(ack.valid_until).to eq(Date.current)
          expect(log.current_acknowledge).to be_nil
        end

        it { expect(subject.call).to be_truthy }

        context 'updates last_seen but not since' do
          before(:each) do
            subject.call
            log.reload
          end
          it { expect(log.loggable).to eq(conn) }
          it { expect(log.action).to eq('GetResource') }
          it { expect(log.level).to eq('WARN') }
          it { expect(log.message).to eq('hier klappt was nicht') }
          it { expect(log.last_seen.to_s).to eq(ts.to_s) }
          it { expect(log.since.to_s).to eq(1.day.before(ts).to_s) }
        end

        context 'updates last_seen and since if existing log is invalid' do
          before(:each) do
            log.update(is_valid: false)
            log.reload
            subject.call
            log.reload
          end
          it { expect(log.loggable).to eq(conn) }
          it { expect(log.action).to eq('GetResource') }
          it { expect(log.level).to eq('WARN') }
          it { expect(log.message).to eq('hier klappt was nicht') }
          it { expect(log.last_seen.to_s).to eq(ts.to_s) }
          it { expect(log.since.to_s).to eq(ts.to_s) }
        end
      end
    end

    describe "with array as message" do
      subject do
        Logs::Creator.new(
          loggable: conn,
          action: "GetResource",
          level: "WARN",
          last_seen: ts,
          message: %w( some array of messages )
        )
      end
      it "concats message to one string" do
        subject.call
        expect(subject.log.message).to eq("some; array; of; messages")
      end
    end
  end
end
