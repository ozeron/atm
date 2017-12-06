require 'spec_helper'
require 'middleware/storage'

describe Middleware::Storage do
  include Rack::Test::Methods
  let(:app) { ->(env) { [200, env, 'app'] } }
  let(:saver) { instance_double('StateSaver') }

  before do
    allow(saver).to receive(:load).and_return({})
    allow(saver).to receive(:save)
  end

  it 'initial state is empty' do
    expect(described_class.new(app, saver: saver).state).to eq({})
  end

  describe '#initialize' do
    subject(:initialized) { described_class.new(app, saver: saver) }

    let(:state) { { '10' => 4 } }

    before do
      allow(saver).to receive(:load).and_return(state)
    end

    it 'calls load from saver object' do
      initialized
      expect(saver).to have_received(:load)
    end

    it 'state equal loaded' do
      expect(initialized.state).to eq(state)
    end
  end

  describe '#call' do
    let(:middleware) { described_class.new(app, saver: saver) }

    describe 'modifies env' do
      let(:env) { {} }
      let(:cached) { { 50 => 10 } }

      before do
        allow(middleware).to receive(:state).and_return(cached)
      end

      it 'add state to env' do
        expect { middleware.call(env) }.to(
          change { env[described_class::ENV_KEY] }.to(cached)
        )
      end
    end

    describe 'cache changes in env' do
      let(:app) do
        lambda do |env|
          env[described_class::ENV_KEY] = last
          [200, env, 'app']
        end
      end

      let(:saver) { instance_double('StateSaver') }
      let(:initial) { { 50 => 10 } }
      let(:last) { { 50 => 12 } }
      let(:env) { { described_class::ENV_KEY => initial } }

      before do
        allow(saver).to receive(:save).with(last)
        allow(saver).to receive(:load).and_return({})
        allow(middleware).to receive(:state).and_return(initial)
      end

      it 'add state to env' do
        expect { middleware.call(env) }.to(
          change { env[described_class::ENV_KEY] }.from(initial).to(last)
        )
      end

      it 'calls saver#save with state' do
        middleware.call(env)
        expect(saver).to have_received(:save).with(last)
      end
    end
  end
end
