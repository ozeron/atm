# frozen_string_literal: true

class Atm
  NOMINALS = [1, 2, 5, 10, 25, 50].freeze
  NOMINALS_S = NOMINALS.map(&:to_s).freeze

  attr_reader :state
  def initialize(state = {})
    validate_hash!(state)
    @state = state
  end

  def to_h
    state.clone
  end

  def load_money(hash = {})
    validate_hash!(hash)
    hash.each do |nominal, value|
      state[nominal.to_i] = state.fetch(nominal, 0) + value
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
    result, change = build_withdraw_hash(fixed_amount)
    raise_withdraw_error!(amount) if change > 0
    apply_withdraw(result)
    result
  end

  private

  def apply_withdraw(result)
    result.each do |k, v|
      state[k] -= v
      next if state[k] >= 0
      raise StandardError, 'Nominal quanity can not be less than zero'
    end
  end

  def build_withdraw_hash(amount)
    hash = NOMINALS.reverse.each_with_object({}) do |nominal, memo|
      will_take = [state.fetch(nominal, 0), amount / nominal].min
      next if will_take.zero?
      memo[nominal] = will_take
      amount -= nominal * will_take
    end
    [hash, amount]
  end

  def raise_withdraw_error!(amount)
    error_msg = <<ERROR
can not withdraw sum: #{amount}. Have only nominals: #{state.keys.join(', ')}
ERROR
    raise ArgumentError, error_msg
  end

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
    return if hash.keys.all? { |k| NOMINALS.include?(k.to_i) }
    error_msg = <<ERROR
only nominals: #{NOMINALS.join(', ')} allowed; received: #{hash.keys.join(', ')}
ERROR
    raise ArgumentError, error_msg
  end
end
