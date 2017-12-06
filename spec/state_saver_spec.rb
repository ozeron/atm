require 'spec_helper'
require 'state_saver'

describe StateSaver do
  let(:saver) { described_class.new }
  let(:data) { { '10' => 2 } }
  let(:dir) { 'tmp' }
  let(:path) { "#{dir}/state.json" }
  let(:content) { '{"10":2}' }

  before do
    allow(FileUtils).to receive(:mkdir_p).with(dir)
  end

  describe('#save') do
    subject(:is_saved) { saver.save(data) }

    before do
      allow(File).to receive(:write)
    end

    it 'save state by path' do
      is_saved
      expect(File).to have_received(:write).with(path, content)
    end

    context 'when directory not exist' do
      it 'calls fileutils' do
        is_saved
        expect(FileUtils).to have_received(:mkdir_p).with(dir)
      end
    end

    context 'when not writable' do
      before do
        allow(File).to receive(:write).with(path, content).and_raise(Errno::ENOENT)
      end

      it 'raise error' do
        expect { is_saved }.to raise_error(Errno::ENOENT)
      end
    end
  end

  describe('#load') do
    subject(:is_loaded) { saver.load }

    before do
      allow(File).to receive(:read).with(path).and_return(content)
      allow(File).to receive(:readable?).with(path).and_return(true)
    end

    it 'return parsed data' do
      is_expected.to eq(data)
    end

    context 'when state not exist' do
      before do
        allow(File).to receive(:read).with(path).and_raise(Errno::ENOENT)
        allow(File).to receive(:readable?).with(path).and_return(false)
      end

      it 'return empty' do
        is_expected.to eq({})
      end
    end
  end
end
