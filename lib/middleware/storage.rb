# frozen_string_literal: true

module Middleware
  class Storage
    ENV_KEY = 'storage.state'

    attr_reader :app
    attr_accessor :state
    def initialize(app)
      @app = app
      @state = {}
    end

    def call(env)
      env[ENV_KEY] = state
      array = app.call(env)
      @state = env[ENV_KEY] if env.key?(ENV_KEY)
      array
    end
  end
end
