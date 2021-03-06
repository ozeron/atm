# frozen_string_literal: true

require 'grape'
require_relative '../atm'
require_relative '../middleware/storage'

module API
  class Atm < Grape::API
    ENV_KEY = 'storage.state'

    prefix :atm
    format :json

    helpers do
      def stored_config
        return {} unless env.key?(ENV_KEY)
        env.fetch(ENV_KEY)
      end

      def atm
        @atm ||= ::Atm.new(stored_config)
      end
    end

    after do
      next if env[ENV_KEY].blank?
      env[ENV_KEY] = atm.to_h
    end

    desc 'return max possible withdraw amount'
    get :max_withdraw do
      { 'amount' => atm.max_withdraw }
    end

    desc 'load money to atm'
    params do
      ::Atm::NOMINALS_S.each do |nominal|
        optional nominal, type: Integer, values: ->(v) { v >= 0 }
      end
      at_least_one_of(*::Atm::NOMINALS_S)
    end
    post :load do
      begin
        atm.load_money(params)
        status 200
        {}
      rescue ArgumentError => e
        status 400
        { error: e.message }
      end
    end

    desc 'withdraw and return money amount'
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
