# frozen_string_literal: true

class Rate < RedisRecord
  fields rates: :hash,
         currency_id: :integer

  validate_uniqueness_of :currency_id
  validate :validate_rates

  private

  def prepare_attributes(attributes = {})
    return attributes unless attributes.any?

    currency = Currency.find_by(code: attributes.stringify_keys['base']) ||
      Currency.find_by(id: attributes.stringify_keys['currency_id'])
    attributes
      .merge(currency_id: currency.id)
      .stringify_keys
      .slice(*self.class.field_names.map(&:to_s))
  end

  def validate_rates
    errors << { rates: 'is empty' } unless rates.any?
  end
end
