# frozen_string_literal: true

class Atm
  NOMINALS = [1, 2, 5, 10, 25, 50].freeze
  attr_reader :state
  def initialize(state = {})
    validate_hash!(state)
    @state = state
  end

  def load_money(hash = {})
    validate_hash!(hash)
    hash.each do |nominal, value|
      state[nominal] = state.fetch(nominal, 0) + value
    end
    self
  end

  def max_withdraw
    state.reduce(0) do |acc, (key, value)|
      acc + key * value
    end
  end

  private

  def validate_hash!(hash)
    validate_nominal_quanity!(hash)
    validate_nominals!(hash)
  end

  def validate_nominal_quanity!(hash)
    return if hash.values.all? { |v| v >= 0 }
    raise ArgumentError, 'Negative papers quanity not allowed'
  end

  def validate_nominals!(hash)
    return if hash.keys.all? { |k| NOMINALS.include?(k) }
    error_msg = <<ERROR
Only nominals: #{NOMINALS.join(', ')} allowed; received: #{hash.keys.join(', ')}
ERROR
    raise ArgumentError, error_msg
  end
end
