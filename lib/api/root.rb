require 'grape-swagger'
require 'atm/api'

module API
  class Root < Grape::API
    mount Atm::API
    add_swagger_documentation
  end
end
