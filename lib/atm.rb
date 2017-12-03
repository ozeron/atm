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

  def withdraw(amount)
    fixed_amount = amount.to_i
    validate_amount!(fixed_amount)
    result = NOMINALS.reverse.each_with_object({}) do |nominal, memo|
      needed = fixed_amount / nominal
      will_take = [state.fetch(nominal, 0), needed].min
      next if will_take.zero?
      state[nominal] -= will_take
      memo[nominal] = will_take
      fixed_amount -= nominal * will_take
    end
    return result if fixed_amount.zero?
    raise ArgumentError, "Can not withdraw sum: #{amount}. Have only nominals: #{state.keys.join(', ')}"
  end

  private

  def validate_amount!(amount)
    validate_amount_bigger_than_zero!(amount)
    validate_amount_less_than_max_withdraw!(amount)
  end

  def validate_amount_bigger_than_zero!(amount)
    return if amount >= 0
    raise ArgumentError, 'Amount should be positive number'
  end

  def validate_amount_less_than_max_withdraw!(amount)
    return if amount < max_withdraw
    raise ArgumentError, "Can not withdraw this sum. You ask for: #{amount}, max is #{max_withdraw}"
  end

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
