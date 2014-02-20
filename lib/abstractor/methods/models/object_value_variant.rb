module Abstractor
  module Methods
    module Models
      module ObjectValueVariant
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :object_value

          base.send :attr_accessible, :object_value, :abstractor_object_value_id, :deleted_at, :value
        end
      end
    end
  end
end
