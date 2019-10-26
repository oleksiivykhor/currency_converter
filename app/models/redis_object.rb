# frozen_string_literal: true

class RedisRecord
  attr_reader :attributes, :old_attributes
  attr_accessor :errors

  ALLOWED_TYPES = { string: :to_s, symbol: :to_sym, integer: :to_i,
                    hash: :to_h, array: :to_a }.freeze

  def initialize(attributes = {})
    @attributes = prepare_attributes attributes
    @old_attributes = {}
    @errors ||= []
  end

  class << self
    def fields(attributes = {})
      return @fields if @fields

      attributes.merge!(id: :integer)
      @fields = attributes
    end

    def field_names
      @field_names ||= fields.keys
    end

    def create(attributes = {})
      record = new(attributes)
      record.save
    end

    def namespace
      "#{ENV['SINATRA_ENV']}_#{to_s.underscore}"
    end

    def id_namespace
      "#{namespace}:id"
    end

    # Search only by one attribute currently
    def find_by(attributes = {})
      where(attributes).first
    end

    # Search only by one attribute currently
    def where(attributes = {})
      field = attributes.keys[0]
      value = attributes.values[0]
      all.select { |r| r.try(field).to_s.downcase.eql? value.to_s.downcase }
    end

    def all
      keys = redis.keys('*').select { |k| k[/#{namespace}:\d+/] }
      return [] unless keys.any?

      redis.mget(keys).each_with_object([]) do |json_str, results|
        results << new(parse_json(json_str))
      end
    end

    # Checks by one attribute
    def exists?(attributes = {})
      field = attributes.keys[0]
      value = attributes.values[0]
      record = find_by(field => value)

      record ? true : false
    end

    def validate(*method_names)
      @validate ||= method_names
    end

    def validate_uniqueness_of(*fields)
      @validate_uniqueness_of ||= fields.push(:id)
    end

    def count
      all.count
    end

    def parse_json(json_str)
      JSON.parse json_str
    end

    def redis
      @redis ||= Redis.current
    end
  end

  def update(attrs = {})
    @old_attributes = attributes
    attrs = attributes.stringify_keys.merge(attrs.stringify_keys)
    @attributes = prepare_attributes attrs
    save(update: true)
  end

  def save(options = {})
    validate_field_names
    validate_types
    self.class.validate.each { |m| send m }
    self.class.validate_uniqueness_of.each { |f| uniqueness_validation f }
    return [false, self] unless valid?

    new_id = redis.incr(self.class.id_namespace) unless options[:update]
    json_str = attributes.merge!(id: new_id).to_json
    redis.set("#{self.class.namespace}:#{new_id}", json_str)

    [true, self]
  end

  def valid?
    errors.any? ? false : true
  end

  private

  def redis
    self.class.redis
  end

  def validate_field_names
    attributes.keys.each do |key|
      next if self.class.field_names.map(&:to_s).include? key.to_s

      errors << { key => 'missing' }
    end
  end

  def validate_types
    attributes.each do |key, value|
      type = self.class.fields.stringify_keys[key.to_s]
      error = "has unsupported type #{type}"
      next errors << { key => error } unless ALLOWED_TYPES.keys.include? type

      type_class = type.to_s.classify.constantize
      error = "value #{value} is not #{type_class}"
      errors << { key => error } unless value.is_a? type_class
    end
  end

  def prepare_attributes(attributes = {})
    attributes
  end

  def method_missing(method, *args, &block)
    return super unless self.class.field_names.include? method

    value = attributes.stringify_keys[method.to_s]
    to_method = ALLOWED_TYPES[self.class.fields.stringify_keys[method.to_s]]

    to_method && value ? value.public_send(to_method) : value
  end

  def respond_to_missing?(method, include_private = false)
    self.class.field_names.include?(method) || super
  end

  def uniqueness_validation(field)
    return unless self.class.exists?(field => try(field))

    records = self.class.where(field => try(field))
    return if records.one? && records[0].id.eql?(id)

    errors << { field => 'already exists' }
  end

  def parse_json(json_str)
    self.class.parse_json json_str
  end
end
