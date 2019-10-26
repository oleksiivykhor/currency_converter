# frozen_string_literal: true

require 'spec_helper'

describe RatesService do
  let(:currency) { :usd }
  let(:service) { described_class.new(currency) }
  let(:response_status) { 200 }
  let(:response_body) { json_fixture(:rates).to_json }
  let(:currencies) do
    json_fixture(:rates)['rates'].keys.map { |c| c.downcase.to_sym }
  end

  before do
    currencies.each do |currency|
      stub_request(:get, 'https://api.exchangeratesapi.io/latest').
        with(query: { base: currency.to_s.upcase }).
        to_return(status: response_status, body: response_body)
    end
  end

  describe '#get_rates' do
    it { expect(service.rates).to be_a Hash }

    context 'when reponse status is not 200' do
      let(:response_status) { 401 }

      it 'returns the empty hash' do
        expect(service).not_to receive(:json)
        expect(service.rates).to eq({})
      end
    end

    context 'when response body has no "rates" key' do
      let(:response_body) { {}.to_json }

      it 'returns the empty hash' do
        expect(service.rates).to eq({})
      end
    end
  end

  describe '#currencies' do
    it { expect(service.currencies.sort).to eq currencies.sort }

    context 'when rates is empty' do
      let(:response_status) { 401 }

      it 'returns the empty array' do
        expect(service.currencies).to eq []
      end
    end
  end

  describe '#update_currencies' do
    before { service.update_currencies }

    it 'creates currencies' do
      expect(Currency.all.map(&:code).sort).to eq service.currencies.sort
    end
  end

  describe '#update_rates' do
    before do
      service.update_currencies
      service.update_rates
    end

    it 'updates/creates rates' do
      expect(Rate.count).to eq service.currencies.count
    end
  end
end
