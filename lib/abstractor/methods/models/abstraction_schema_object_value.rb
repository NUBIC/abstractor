module Abstractor
  module Methods
    module Models
      module AbstractionSchemaObjectValue
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstraction_schema
          base.send :belongs_to, :object_value

          base.send :attr_accessible, :abstraction_schema, :abstraction_schema_id, :object_value, :object_value_id
        end
      end
    end
  end
end