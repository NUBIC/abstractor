module Abstractor
  module Methods
    module Models
      module AbstractorSubjectGroup
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :has_many, :abstractor_subject_group_members
          base.send :has_many, :abstractor_subjects, :through => :abstractor_subject_group_members
          base.send :has_many, :abstractor_abstraction_groups
          base.send :has_many, :abstractor_abstractions, :through => :abstractor_abstraction_groups

          # base.send :attr_accessible, :deleted_at, :name
          # Validations
          base.send :validates, :cardinality, numericality: { only_integer: true, greater_than: 0 }, unless: Proc.new { |a| a.cardinality.blank? }
          base.send(:include, InstanceMethods)
        end

        module InstanceMethods
          def has_subtype?(s)
            subtype == s
          end
        end
      end
    end
  end
end
