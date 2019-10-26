# frozen_string_literal: true

require 'spec_helper'

describe CurrencyCalculationService do
  let(:service) { described_class.new(attributes) }
  let(:rates_service) { RatesService.new }
  let(:currencies) do
    json_fixture(:rates)['rates'].keys.map { |c| c.downcase.to_sym }
  end

  before do
    currencies.each do |currency|
      stub_request(:get, 'https://api.exchangeratesapi.io/latest').
        with(query: { base: currency.to_s.upcase }).
        to_return(status: 200, body: json_fixture(:rates).to_json)
    end

    rates_service.update_currencies
    rates_service.update_rates
  end

  context 'when from currency USD and to currency CAD' do
    let(:attributes) do
      {
        from: { currency: :usd, amount: 10.0 },
        to: { currency: :cad, amount: 0.0 }
      }
    end

    it 'calculates amounts' do
      expect(service.calculate).
        to eq attributes.merge(to: { amount: 14.51, currency: :cad })
    end
  end

  context 'when from currency RON and to currency BRL' do
    let(:attributes) do
      {
        from: { currency: :ron, amount: 123.0 },
        to: { currency: :brl, amount: 0.0 }
      }
    end

    it 'calculates amounts' do
      expect(service.calculate).
        to eq attributes.merge(to: { amount: 550.20, currency: :brl })
    end
  end
end
