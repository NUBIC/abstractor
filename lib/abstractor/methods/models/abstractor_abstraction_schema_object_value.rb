module Abstractor
  module Methods
    module Models
      module AbstractorAbstractionSchemaObjectValue
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstractor_abstraction_schema
          base.send :belongs_to, :abstractor_object_value

          # base.send :attr_accessible, :abstractor_abstraction_schema, :abstractor_abstraction_schema_id, :abstractor_object_value, :abstractor_object_value_id
        end
      end
    end
  end
end