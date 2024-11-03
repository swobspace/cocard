# frozen_string_literal: true

require 'rails_helper'
module TerminalWorkplaces
  RSpec.describe Crupdator do
    # let!(:ts) { Time.current }
    let(:ct)  { FactoryBot.create(:card_terminal, :with_mac) }

    subject do 
      TerminalWorkplaces::Crupdator.new(
        card_terminal: ct,
        mandant: "Mandy",
        client_system: "SlowMed",
        workplaces: ['PC002', 'PC003']
      )
    end

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(TerminalWorkplaces::Crupdator) }
      it { expect(subject.respond_to?(:call)).to be_truthy }
    end

    describe '#new' do
      context 'without params' do
        it 'raises a KeyError' do
          expect do
            Crupdator.new()
          end.to raise_error(KeyError)
        end
      end
    end

    describe '#call' do
      context 'with new workplaces' do
        it 'create new workplaces' do
          expect do
            subject.call
          end.to change(Workplace, :count).by(2)
        end

        it 'updates last_seen' do
          subject.call
          current = Workplace.where('last_seen > ?', 1.minute.before(Time.current)).count
          expect(current).to eq(2)
        end

        it 'creates new terminal_workplaces' do
          expect do
            subject.call
          end.to change(TerminalWorkplace, :count).by(2)
        end
      end

      context "with existing workplaces" do
        let!(:wp1) { FactoryBot.create(:workplace, name: 'PC001') }
        let!(:wp2) { FactoryBot.create(:workplace, name: 'PC002') }
        let!(:wp3) { FactoryBot.create(:workplace, name: 'PC003') }

        context "with no existing terminal_workplaces" do
          it 'does not create new workplaces' do
            expect do
              subject.call
            end.to change(Workplace, :count).by(0)
          end

          it 'updates last_seen' do
            subject.call
            current = Workplace.where('last_seen > ?', 1.minute.before(Time.current))
                               .count
            expect(current).to eq(2)
          end

          it 'creates new terminal_workplaces' do
            expect do
              subject.call
            end.to change(TerminalWorkplace, :count).by(2)
          end
        end

        context "with existing terminal_workplaces" do
          let!(:twp1)  do
            FactoryBot.create(:terminal_workplace, 
              card_terminal: ct,
              mandant: 'Mandy',
              client_system: 'SlowMed',
              workplace: wp1,
              updated_at: 1.day.before(Time.current)
            )
          end
          let!(:twp2)  do
            FactoryBot.create(:terminal_workplace, 
              card_terminal: ct,
              mandant: 'Mandy',
              client_system: 'SlowMed',
              workplace: wp2,
              updated_at: 1.day.before(Time.current)
            )
          end

          it 'does not create new terminal_workplaces' do
            expect do
              subject.call
            end.to change(TerminalWorkplace, :count).by(0)
          end

          it 'adds one terminal_workplace and deletes another' do
            expect(TerminalWorkplace.all).to contain_exactly(twp1, twp2)
            result = subject.call
            expect(result).to contain_exactly(wp1)
            expect(TerminalWorkplace.all).to include(twp2)
            expect(TerminalWorkplace.all).not_to include(twp1)
            expect(TerminalWorkplace.count).to eq(2)
            wp1.reload; wp2.reload 
            expect(wp1.updated_at).to be > 1.minute.before(Time.current)
          end
        end
      end
    end
  end
end
