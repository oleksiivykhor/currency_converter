# frozen_string_literal: true

require 'spec_helper'

describe Rate do
  let(:params) { json_fixture :rates }

  before do
    Currency.create(code: :eur)
    described_class.create params
  end

  it 'creates rate succesfully' do
    expect(described_class.count).to eq 1
  end

  context 'when rate with eur currency already exists' do
    let!(:rate) { described_class.create params }

    it 'does not save the record' do
      expect(described_class.count).to eq 1
      expect(rate[1]).not_to be_valid
      expect(rate[1].errors).
        to(be_any { |e| e[:currency_id].eql? 'already exists' })
    end
  end

  context 'when rates hash is empty' do
    let(:rate) { described_class.create(params) }

    before { params.merge!(rates: {}) }

    it 'does not save the record' do
      expect(described_class.count).to eq 1
      expect(rate[1]).not_to be_valid
      expect(rate[1].errors).
        to(be_any { |e| e[:rates].eql? 'is empty' })
    end
  end

  describe '#update' do
    let(:rate) { described_class.all[0] }
    let!(:currency) { Currency.create(code: :usd) }

    before { rate.update(params.merge(base: :usd)) }

    it 'updates the record' do
      expect(described_class.count).to eq 1
      expect(rate.currency_id).to eq currency[1].id
    end
  end
end
