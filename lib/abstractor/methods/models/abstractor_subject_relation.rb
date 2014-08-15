module Abstractor
  module Methods
    module Models
      module AbstractorSubjectRelation
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstractor_relation_type
          base.send :belongs_to, :object,   :class_name => "Abstractor::AbstractorSubject", :foreign_key => "object_id"
          base.send :belongs_to, :subject,  :class_name => "Abstractor::AbstractorSubject", :foreign_key => "subject_id"

          # base.send :attr_accessible, :abstractor_relation_type, :abstractor_relation_type_id, :object, :object_id, :subject, :subject_id, :deleted_at
        end
      end
    end
  end
end