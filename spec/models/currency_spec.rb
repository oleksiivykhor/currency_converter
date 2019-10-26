# frozen_string_literal: true

require 'spec_helper'

describe Currency do
  before { described_class.create(code: :usd) }

  it 'creates currency succesfully' do
    expect(described_class.count).to eq 1
  end

  context 'when currency code already exists' do
    let(:invalid_currency) { described_class.create(code: :usd) }

    it 'does not save the record' do
      expect(invalid_currency[1]).not_to be_valid
      expect(described_class.count).to eq 1
      expect(invalid_currency[1].errors).
        to(be_any { |e| e[:code].eql? 'already exists' })
    end
  end

  describe '#update' do
    let(:currency) { described_class.all[0] }

    before { currency.update(code: :try) }

    it 'updates the record' do
      expect(described_class.count).to eq 1
      expect(currency.code).to eq :try
    end
  end
end
