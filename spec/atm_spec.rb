require 'spec_helper'
require 'atm'

describe Atm do
  let(:atm) { described_class.new }

  describe '#max_withdraw' do
    context 'with empty atm' do
      it 'zero' do
        expect(atm.max_withdraw).to eq(0)
      end
    end

    context 'with 2 50 papers' do
      let(:state) { { 2 => 50 } }

      let(:atm) { described_class.new(state) }

      it 'zero' do
        expect(atm.max_withdraw).to eq(100)
      end
    end

    context 'with wrong initial nominals' do
      let(:hash) { { 12 => 2 } }

      it 'raise ArgumentError error' do
        expect { described_class.new(hash) }.to raise_error(ArgumentError)
      end
    end

    context 'with wrong initial nominals' do
      let(:hash) { { 12 => 2 } }

      it 'raise ArgumentError error' do
        expect { described_class.new(hash) }.to raise_error(ArgumentError)
      end
    end

    context 'with negative nominal quanity' do
      let(:hash) { { 10 => -2 } }

      it 'raise ArgumentError error' do
        expect { described_class.new(hash) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#load_money' do
    it 'return self' do
      expect(atm.load_money).to be_a described_class
    end
    context 'with empty hash' do
      it 'not change' do
        expect { atm.load_money }.not_to(change { atm.max_withdraw })
      end
    end

    context 'with nominal 2 50 papers' do
      let(:hash) { { 50 => 2 } }

      it 'change max_withdraw by 100' do
        expect { atm.load_money(hash) }.to change { atm.max_withdraw }.by(100)
      end
    end

    context 'with negative value of papers' do
      let(:hash) { { 50 => -2 } }

      it 'raise ArgumentError error' do
        expect { atm.load_money(hash) }.to raise_error(ArgumentError)
      end
    end

    context 'with wrong nominals of papers' do
      let(:hash) { { 7 => 2 } }

      it 'raise ArgumentError error' do
        expect { atm.load_money(hash) }.to raise_error(ArgumentError)
      end
    end
  end
end
