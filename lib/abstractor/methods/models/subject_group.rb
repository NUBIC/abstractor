module Abstractor
  module Methods
    module Models
      module SubjectGroup
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :has_many, :subject_group_members
          base.send :has_many, :subjects, :through => :subject_group_members
          base.send :has_many, :abstraction_groups
          base.send :has_many, :abstractions, :through => :abstraction_groups

          base.send :attr_accessible, :deleted_at, :name
        end
      end
    end
  end
end
