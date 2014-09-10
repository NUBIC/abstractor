module Abstractor
  module Methods
    module Models
      module AbstractorAbstractionSchemaPredicateVariant
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstractor_abstraction_schema

          # base.send :attr_accessible, :abstractor_abstraction_schema, :abstractor_abstraction_schema_id, :deleted_at, :value
        end
      end
    end
  end
end
