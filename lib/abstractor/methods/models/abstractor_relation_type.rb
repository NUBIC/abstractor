module Abstractor
  module Methods
    module Models
      module AbstractorRelationType
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :has_many, :abstractor_abstraction_schema_relations
          base.send :has_many, :subject_relations

          # base.send :attr_accessible, :deleted_at, :name
        end
      end
    end
  end
end