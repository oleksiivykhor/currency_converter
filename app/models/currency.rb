# frozen_string_literal: true

class Currency < RedisRecord
  fields code: :symbol

  validate_uniqueness_of :code
end
