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

  describe '#withdraw' do
    subject { atm.withdraw(amount) }

    let(:state) { { 50 => 2 } }
    let(:atm) { described_class.new(state) }
    let(:amount) { 50 }
    let(:result) { { 50 => 1 } }

    it 'return hash with nominals and quanity' do
      is_expected.to eq(result)
    end

    it 'change max_withdraw by sum withdrawed' do
      expect { subject }.to change { atm.max_withdraw }.by(-1 * amount)
    end

    context 'when received like in task' do
      let(:state) { { 50 => 3, 25 => 4 } }
      let(:result) { { 50 => 3, 25 => 2 } }
      let(:amount) { 200 }

      it { is_expected.to eq(result) }
      it { expect { subject }.to change { atm.max_withdraw }.by(-1 * amount) }
    end

    context 'when amount is complex' do
      let(:state) { { 50 => 2, 25 => 1, 10 => 3, 2 => 3, 1 => 1 } }
      let(:result) { { 50 => 1, 25 => 1, 10 => 1, 2 => 2, 1 => 1 } }
      let(:amount) { 90 }

      it { is_expected.to eq(result) }
    end

    context 'when amount is bigger than max_withdraw' do
      let(:amount) { 500 }

      it 'raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when amount is less than zero' do
      let(:amount) { -50 }

      it 'raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
      it { expect { subject rescue ArgumentError }.not_to(change { atm.max_withdraw }) }
    end

    context 'when amount can not be given' do
      let(:amount) { 60 }

      it 'return hash with nominals and quanity' do
        expect { subject }.to raise_error(ArgumentError)
      end
      it { expect { subject rescue ArgumentError }.not_to(change { atm.max_withdraw }) }
    end

    context 'when amount can not be converted to int' do
      let(:amount) { 14.3 }

      it 'return hash with nominals and quanity' do
        expect { subject }.to raise_error(ArgumentError)
      end
      it { expect { subject rescue ArgumentError }.not_to(change { atm.max_withdraw }) }
    end

    context 'when amount can be converted to int' do
      let(:amount) { 50.0 }

      it 'return hash with nominals and quanity' do
        is_expected.to eq(result)
      end
      it { expect { subject }.to change { atm.max_withdraw }.by(-1 * amount) }
    end
  end
end
