require 'spec_helper'
require 'atm/api'

describe Atm::API do
  include Rack::Test::Methods

  def app
    described_class
  end

  describe 'GET /api/max_withdraw' do
    let(:result) { { 'amount' => 0 } }

    before do
      get 'api/max_withdraw'
    end

    it { expect(last_response.status).to eq(200) }
    it 'returns number of possible maximum withdraw' do
      expect(JSON.parse(last_response.body)).to eq(result)
    end
  end

  describe 'POST /api/load' do
    # define in let blocks
    # @param err_regexp [Regex]
    # @param params [Hash]
    shared_examples 'failed_request' do |url|
      before do
        env ||= {}
        env['CONTENT_TYPE'] = 'application/json'
        post url, params.to_json, env
      end

      it { expect(last_response.status).to eq(400) }
      it do
        expect(JSON.parse(last_response.body).fetch('error')).to match(err_regexp)
      end
    end

    context 'when ok' do
      before do
        post '/api/load', '50' => 10
      end

      it { expect(last_response.status).to eq(200) }
    end

    context 'when wrong nominals received' do
      let(:params) { { 10 => 5, 13 => 10 } }
      let(:err_regexp) { /only nominals.*?allowed;/ }

      include_examples 'failed_request', '/api/load'
    end

    context 'when no nominal received' do
      let(:params) { {} }
      let(:err_regexp) { /are missing, at least one parameter/ }

      include_examples 'failed_request', '/api/load'
    end

    context 'when negative quanity received' do
      let(:params) { { 10 => -50 } }
      let(:err_regexp) { /not have a valid value/ }

      include_examples 'failed_request', '/api/load'
    end
  end


  describe 'POST /api/withdraw' do
    shared_examples 'failed_request' do
      before do
        post '/api/withdraw', params, env
      end

      it { expect(last_response.status).to eq(400) }
      it do
        expect(JSON.parse(last_response.body).fetch('error')).to match(err_regexp)
      end
    end


    let(:env) do
      { Middleware::Storage::ENV_KEY => state.clone }
    end
    let(:params) { { 'amount' => 50 } }
    let(:state) { { } }

    describe 'mutating env during request' do
      let(:state) { { 50 =>2, 10 => 10 } }
      let(:end_state) { { 50 => 1, 10 => 10 } }

      it 'change env' do
        expect { post '/api/withdraw', params, env }.to(
          change { env[Middleware::Storage::ENV_KEY] }.to(end_state)
        )
      end
    end

    context 'when ok' do
      let(:result) { { '50' => 1 } }
      let(:state) { { 50 => 2 } }

      before do
        post '/api/withdraw', params, env
      end

      it { expect(last_response.status).to eq(200) }
      it { expect(JSON.parse(last_response.body)).to eq(result) }
    end

    context 'when amount is bigger then atm has' do
      let(:params) { { amount: 150 } }
      let(:err_regexp) { /can not withdraw this sum. you ask for.*?max is/ }
      let(:state) { { 50 => 2 } }

      include_examples 'failed_request'
    end

    context 'when amount is negative' do
      let(:params) { { amount: -10 } }
      let(:err_regexp) { /amount does not have a valid value/ }
      let(:state) { { 50 => 2 } }

      include_examples 'failed_request'
    end

    context 'when atm has wrong nominals' do
      let(:params) { { amount: 10 } }
      let(:err_regexp) { /can not withdraw sum.*have only nominals?/ }
      let(:state) { { 50 => 2, 5 => 1 } }

      include_examples 'failed_request'
    end
  end
end
