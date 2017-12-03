require 'grape'
require_relative '../atm'

class Atm
  class API < Grape::API
    prefix :api
    format :json

    helpers do
      def atm
        @atm ||= Atm.new
      end
    end

    get :max_withdraw do
      { 'amount' => atm.max_withdraw }
    end
  end
end
