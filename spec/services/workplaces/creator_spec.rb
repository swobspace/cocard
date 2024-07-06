# frozen_string_literal: true

require 'rails_helper'
module Workplaces
  RSpec.describe Creator do
    let(:wp_hash) do
      { name: 'NXC-NB-0004', description: 'Hauptbenutzer Quoro' }
    end

    subject do 
      Workplaces::Creator.new(
        attributes: wp_hash, 
        update_only: true, 
        force_update: false
      )
    end

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(Workplaces::Creator) }
      it { expect(subject.respond_to?(:save)).to be_truthy }
    end

    describe '#new' do
      context 'without :attributes' do
        it 'raises a KeyError' do
          expect do
            Creator.new()
          end.to raise_error(KeyError)
        end
      end
    end

    describe '#save' do
      context 'a new workplace' do
        let(:wp) { subject.save; subject.workplace }
        it 'does not create a new record' do
          expect do
            subject.save
          end.not_to change(Workplace, :count)
          expect(subject.workplace).to be_kind_of(Workplace)
          expect(subject.workplace).not_to be_persisted
        end
        it { expect(subject.save).to be_falsey }

        context 'with update_only false' do
          subject { Workplaces::Creator.new(attributes: wp_hash, update_only: false) }

          it 'creates a new record' do
            expect do
              subject.save
            end.to change(Workplace, :count).by(1)
            expect(subject.workplace).to be_kind_of(Workplace)
            expect(subject.workplace).to be_persisted
          end
          it { expect(subject.save).to be_truthy }
          it { expect(wp.name).to eq("NXC-NB-0004") }
          it { expect(wp.description.to_plain_text).to eq("Hauptbenutzer Quoro") }
        end
      end

      context 'with an existing workplace' do
        let!(:wp) do
          FactoryBot.create(:workplace, 
            name: 'NXC-NB-0004',
            description: "some other description"
          )
        end

        it 'does not create a new record' do
          expect {
            subject.save
          }.not_to change(Workplace, :count)
          expect(subject.workplace).to be_kind_of(Workplace)
          expect(subject.workplace).to eq(wp)
        end

        context "with force_update false" do
          it { expect(subject.save).to be_falsey }
          it { subject.save; wp.reload;
               expect(wp.description.to_plain_text).to eq("some other description") }
        end

        context "with force_update true" do
          subject { Workplaces::Creator.new(attributes: wp_hash, force_update: true) }
          it { expect(subject.save).to be_truthy }
          it { subject.save; wp.reload;
               expect(wp.description.to_plain_text).to eq("Hauptbenutzer Quoro") }
        end

      end
    end
  end
end
