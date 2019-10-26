# frozen_string_literal: true

class RatesService
  attr_reader :currency

  def initialize(currency = 'USD')
    @currency = currency.to_s.upcase
  end

  def update_currencies
    currencies.each do |currency|
      next if Currency.exists?(code: currency)

      Currency.create(code: currency)
    end
  end

  def update_rates
    @old_currency = currency
    currencies.each do |curr|
      @currency = curr.to_s.upcase
      currency_id = Currency.find_by(code: curr)&.id
      next unless currency_id

      rate = Rate.find_by(currency_id: currency_id)
      rates_attrs = { rates: rates, base: curr }
      rate ? rate.update(rates_attrs) : Rate.create(rates_attrs)
    end
  end

  def rates
    response = client.get('latest', base: currency)
    return {} unless response.status.eql? 200

    json(response)['rates'] || {}
  end

  def currencies
    rates.keys.map { |c| c.downcase.to_sym }
  end

  private

  def client
    @client ||= Faraday.new('https://api.exchangeratesapi.io') do |request|
      request.request :url_encoded
      request.adapter Faraday.default_adapter
      request.headers['Content-Type'] = 'application/json'
    end
  end

  def json(response)
    JSON.parse response.body
  end
end
