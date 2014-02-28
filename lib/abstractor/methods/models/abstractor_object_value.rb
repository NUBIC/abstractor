module Abstractor
  module Methods
    module Models
      module AbstractorObjectValue
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :has_many, :abstractor_object_value_variants
          base.send :has_many, :abstractor_abstraction_schema_object_values
          base.send :has_many, :abstractor_abstraction_schemas, :through => :abstractor_abstraction_schema_object_values

          #Validations
          base.send :attr_accessible, :value, :abstractor_object_value_variants, :abstractor_abstraction_schema_object_values, :abstractor_abstraction_schemas
        end

        # Instance Methods
        def object_variants
          [value].concat(abstractor_object_value_variants.map(&:value))
        end
      end
    end
  end
end
