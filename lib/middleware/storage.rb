# frozen_string_literal: true
require_relative '../state_saver'

module Middleware
  class Storage
    ENV_KEY = 'storage.state'.freeze

    attr_reader :app, :saver, :state
    def initialize(app, saver: StateSaver.new)
      @app = app
      @saver = saver
      @state = saver.load
    end

    def call(env)
      env[ENV_KEY] = state
      array = app.call(env)
      @state = env[ENV_KEY] if env.key?(ENV_KEY)
      callbacks
      array
    end

    private

    def callbacks
      saver.save(@state)
    end
  end
end
