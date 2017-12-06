# frozen_string_literal: true
require 'oj'

class StateSaver
  DEFAULT_PATH = 'tmp/state.json'.freeze

  attr_reader :path
  def initialize(path = DEFAULT_PATH)
    @path = path
  end

  def save(state)
    check_directory!
    File.write(path, Oj.dump(state))
  end

  def load
    return {} unless File.readable?(path)
    str = File.read(path)
    Oj.load(str)
  end

  private

  def check_directory!
    dir = Pathname.new(path).dirname.to_s
    FileUtils.mkdir_p(dir)
  end
end
