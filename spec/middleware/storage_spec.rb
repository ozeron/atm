require 'spec_helper'
require 'middleware/storage'

describe Middleware::Storage do
  include Rack::Test::Methods
  let(:app) { ->(env) { [200, env, 'app'] } }

  it 'initial state is empty' do
    expect(described_class.new(app).state).to eq({})
  end

  describe 'modifies env' do
    let(:middleware) { described_class.new(app) }
    let(:env) { {} }
    let(:cached) { { 50 => 10 } }

    before do
      allow(middleware).to receive(:state).and_return(50 => 10)
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

    let(:middleware) { described_class.new(app) }
    let(:initial) { { 50 => 10 } }
    let(:last) { { 50 => 12 } }
    let(:env) { { described_class::ENV_KEY => initial } }

    before do
      allow(middleware).to receive(:state).and_return(initial)
    end

    it 'add state to env' do
      expect { middleware.call(env) }.to(
        change { env[described_class::ENV_KEY] }.from(initial).to(last)
      )
    end
  end
end
