# frozen_string_literal: true

require 'rails_helper'
module Notes
  RSpec.describe Processor do
    let!(:ts)   { Time.current }
    let(:log) { FactoryBot.create(:log, :with_connector) }
    let(:note) do 
      FactoryBot.create(:note, 
        notable_id: log.id, notable_type: 'Log',
        type: Note.types[:acknowledge],
        message: "some more information"
      )
    end

    subject { Notes::Processor.new(note: note) }

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(Notes::Processor) }
      it { expect(subject.respond_to?(:call)).to be_truthy }
    end

    describe '#new' do
      context 'without params' do
        it 'raises a KeyError' do
          expect do
            Processor.new()
          end.to raise_error(KeyError)
        end
      end
    end

    describe '#call(nix)' do
      it "raises a runtime error" do
        expect {
          subject.call(:nix)
        }.to raise_error(RuntimeError)
      end
    end

    describe '#call(create)' do
      it "updates log.acknowledge to new ack" do
        expect(log.acknowledge).to be_nil
        subject.call(:create)
        log.reload
        expect(log.acknowledge_id).to eq(note.id)
      end
    end

    describe '#call(update)' do
      context "with current ack" do
        it "updates log.acknowledge" do
          expect(log.acknowledge).to be_nil
          subject.call(:update)
          log.reload
          expect(log.acknowledge_id).to eq(note.id)
        end
      end

      context "with outdated ack" do
        it "deletes log.acknowledge" do
          log.update(acknowledge_id: note.id)
          log.reload
          expect(log.acknowledge_id).to eq(note.id)
          note.update(valid_until: 1.day.before(Time.current))
          subject.call(:update)
          log.reload
          expect(log.acknowledge_id).to be_nil
        end
      end
    end

    describe '#call(destroy)' do
      it "updates log.acknowledge to nil" do
        log.update(acknowledge_id: note.id)
        log.reload
        expect(log.acknowledge_id).to eq(note.id)
        note.destroy
        subject.call(:destroy)
        log.reload
        expect(log.acknowledge_id).to be_nil
      end
    end

  end
end
