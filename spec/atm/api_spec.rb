require 'spec_helper'
require 'atm/api'

describe Atm::API do
  include Rack::Test::Methods

  def app
    described_class
  end

  # define in let blocks
  # @param err_regexp [Regex]
  # @param params [Hash]
  shared_examples 'failed_request' do |url|
    before do
      post url, params.to_json, 'CONTENT_TYPE' => 'application/json'
    end

    it { expect(last_response.status).to eq(400) }
    it do
      expect(JSON.parse(last_response.body).fetch('error')).to match(err_regexp)
    end
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
    context 'when ok' do
      before do
        post '/api/load', '50' => 10
      end

      it { expect(last_response.status).to eq(201) }
    end

    context 'when wrong nominals received' do
      let(:params) { { 10 => 5, 13 => 10 } }
      let(:err_regexp) { /only nominals.*?allowed;/ }

      it_behaves_like 'failed_request', '/api/load'
    end

    context 'when no nominal received' do
      let(:params) { {} }
      let(:err_regexp) { /are missing, at least one parameter/ }

      it_behaves_like 'failed_request', '/api/load'
    end

    context 'when negative quanity received' do
      let(:params) { { 10 => -50 } }
      let(:err_regexp) { /not have a valid value/ }

      it_behaves_like 'failed_request', '/api/load'
    end
  end

end
