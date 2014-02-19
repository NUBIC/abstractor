module Abstractor
  module Methods
    module Models
      module AbstractionSchemaPredicateVariant
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstraction_schema

          # base.send :attr_accessible :abstraction_schema, :abstraction_schema_id, :deleted_at, :value
        end
      end
    end
  end
end
