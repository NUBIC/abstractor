module Abstractor
  module Methods
    module Models
      module SubjectGroupMember
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :subject_group
          base.send :belongs_to, :abstractor_subject, class_name: 'Abstractor::Subject', foreign_key: :abstractor_subject_id

          # base.send :attr_accessible :subject_group, :abstractor_subject_group_id, :subject, :abstractor_subject_id, :display_order, :deleted_at
        end
      end
    end
  end
end