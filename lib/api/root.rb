# frozen_string_literal: true

require 'grape-swagger'
require 'api/atm'

module API
  class Root < Grape::API
    mount API::Atm
    add_swagger_documentation
  end
end
