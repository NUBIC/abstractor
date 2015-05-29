module Abstractor
  module Methods
    module Models
      module AbstractorObjectType
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :has_many, :abstractor_abstraction_schemas

          base.send(:include, InstanceMethods)
        end

        module InstanceMethods
          def number?
            self.value == Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_NUMBER
          end
        end
      end
    end
  end
end