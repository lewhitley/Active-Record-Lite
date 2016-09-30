require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    eval(class_name)
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] ||= "#{name}_id".to_sym
    @primary_key = options[:primary_key] ||= :id
    @class_name = options[:class_name] ||= name.to_s.camelcase
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    foreign_key = "#{self_class_name.to_s.underscore}_id".to_sym
    @foreign_key = options[:foreign_key] ||= foreign_key
    @primary_key = options[:primary_key] ||= :id
    @class_name = options[:class_name] ||= name.to_s.singularize.camelcase
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    @options = BelongsToOptions.new(name, options)

    define_method ("#{name}") do
      foreign_val = self.send(@options.foreign_key)
      eval(@options.class_name).where(@options.primary_key => foreign_val).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)

    define_method ("#{name}") do
      primary_val = self.send(options.primary_key)
      eval(options.class_name).where(options.foreign_key => primary_val)
    end
  end

  def assoc_options
    belongs_to_options = @options || {}
    if @options
      belongs_to_options
    end
    belongs_to_options
  end
end

class SQLObject
  extend Associatable
  # Mixin Associatable here...
end
