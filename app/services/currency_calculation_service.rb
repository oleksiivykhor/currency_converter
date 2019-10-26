# frozen_string_literal: true

class CurrencyCalculationService
  attr_reader :from_currency,
              :from_amount,
              :to_currency

  def initialize(attributes = {})
    @from_currency = find_currency(attributes.dig(:from, :currency) || :usd)
    @from_amount = attributes.dig(:from, :amount).to_f
    @to_currency = find_currency(attributes.dig(:to, :currency) || :usd)
  end

  def calculate
    rates = find_rate from_currency
    results = {
      from: { currency: from_currency.code, amount: from_amount.to_f },
      to: { currency: to_currency.code, amount: 0 }
    }
    coeff = rates.rates.stringify_keys[to_currency.code.to_s.upcase] || 0
    amount = (from_amount * coeff.to_f).round(2)
    results[:to][:amount] = amount

    results
  end

  private

  def find_currency(currency)
    Currency.find_by(code: currency)
  end

  def find_rate(currency)
    Rate.find_by(currency_id: currency.id)
  end
end
