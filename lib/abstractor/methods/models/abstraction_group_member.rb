module Abstractor
  module Methods
    module Models
      module AbstractionGroupMember
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstraction_group
          base.send :belongs_to, :abstraction

          base.send :attr_accessible, :abstraction_group, :abstraction_group_id, :abstraction, :abstraction_id, :deleted_at
        end
      end
    end
  end
end
