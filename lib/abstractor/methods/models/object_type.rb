module Abstractor
  module Methods
    module Models
      module ObjectType
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :has_many, :abstraction_schemas

          # base.send :attr_accessible :deleted_at, :value
        end
      end
    end
  end
end