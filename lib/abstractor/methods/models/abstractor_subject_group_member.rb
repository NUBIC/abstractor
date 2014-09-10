module Abstractor
  module Methods
    module Models
      module AbstractorSubjectGroupMember
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstractor_subject_group
          base.send :belongs_to, :abstractor_subject

          # base.send :attr_accessible, :abstractor_subject_group, :abstractor_subject_group_id, :abstractor_subject_id, :display_order, :deleted_at, :abstractor_subject
        end
      end
    end
  end
end