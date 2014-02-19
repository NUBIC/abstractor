module Abstractor
  module Methods
    module Models
      module AbstractionSchema
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :object_type
          base.send :has_many, :abstractor_subjects, :class_name => "Abstractor::Subject", :foreign_key => "abstraction_schema_id"
          base.send :has_many, :abstraction_schema_predicate_variants
          base.send :has_many, :abstraction_schema_object_values
          base.send :has_many, :object_values, :through => :abstraction_schema_object_values
          base.send :has_many, :object_relations,   :class_name => "Abstractor::AbstractionSchemaRelation", :foreign_key => "object_id"
          base.send :has_many, :subject_relations,  :class_name => "Abstractor::AbstractionSchemaRelation", :foreign_key => "subject_id"

          # base.send :attr_accessible :object_type, :object_type_id, :display_name, :predicate, :preferred_name, :deleted_at
        end

        # Instance Methods
        def predicate_variants
          [preferred_name].concat(abstraction_schema_predicate_variants.map(&:value))
        end
      end
    end
  end
end
