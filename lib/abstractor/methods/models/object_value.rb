module Abstractor
  module Methods
    module Models
      module ObjectValue
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :has_many, :object_value_variants
          base.send :has_many, :abstraction_schema_object_values
          base.send :has_many, :abstraction_schemas, :through => :abstraction_schema_object_values

          #Validations
          # base.send :attr_accessible :value
        end

        # Instance Methods

        def object_variants
          [value].concat(object_value_variants.map(&:value))
        end
      end
    end
  end
end
