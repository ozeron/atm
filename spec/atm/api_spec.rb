require 'spec_helper'
require 'atm/api'

describe Atm::API do
  include Rack::Test::Methods

  def app
    described_class
  end

  describe 'GET /api/max_withdraw' do
    before do
      get 'api/max_withdraw'
    end
    it { expect(last_response.status).to eq(200) }
    it 'returns number of possible maximum withdraw' do
      expect(JSON.parse(last_response.body)).to eq(({ "amount" => 0 }))
    end
  end
end
