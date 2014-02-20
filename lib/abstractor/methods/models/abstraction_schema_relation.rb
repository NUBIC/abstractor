module Abstractor
  module Methods
    module Models
      module AbstractionSchemaRelation
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :relation_type
          base.send :belongs_to, :object, :class_name => "Abstractor::AbstractionSchema", :foreign_key => "object_id"
          base.send :belongs_to, :subject,  :class_name => "Abstractor::AbstractionSchema", :foreign_key => "subject_id"

          base.send :attr_accessible, :relation_type, :relation_type_id, :object, :object_id, :subject, :subject_id, :deleted_at
        end
      end
    end
  end
end
