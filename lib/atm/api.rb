require 'grape'
require_relative '../atm'
require_relative '../middleware/storage'

class Atm
  class API < Grape::API
    prefix :api
    format :json

    helpers do
      def stored_config
        return {} unless env.key?(Middleware::Storage::ENV_KEY)
        env.fetch(Middleware::Storage::ENV_KEY)
      end

      def atm
        @atm ||= Atm.new(stored_config)
      end
    end

    after do
      next if env[Middleware::Storage::ENV_KEY].blank?
      env[Middleware::Storage::ENV_KEY] = atm.to_h
    end

    get :max_withdraw do
      { 'amount' => atm.max_withdraw }
    end

    params do
      Atm::NOMINALS_S.each do |nominal|
        optional nominal, type: Integer, values: ->(v) { v >= 0 }
      end
      at_least_one_of(*Atm::NOMINALS_S)
    end
    post :load do
      begin
        atm.load_money(params)
        {}
      rescue ArgumentError => e
        status 400
        { error: e.message }
      end
    end

    params do
      requires :amount, type: Integer, values: ->(v) { v >= 0 }
    end
    post :withdraw do
      begin
        amount = params.fetch(:amount)
        status 200
        atm.withdraw(amount)
      rescue ArgumentError => e
        status 400
        { error: e.message }
      end
    end
  end
end
