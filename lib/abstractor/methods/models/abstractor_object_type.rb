module Abstractor
  module Methods
    module Models
      module AbstractorObjectType
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :has_many, :abstractor_abstraction_schemas

          # base.send :attr_accessible, :deleted_at, :value
        end
      end
    end
  end
end