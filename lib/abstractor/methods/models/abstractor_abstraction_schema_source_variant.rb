module Abstractor
  module Methods
    module Models
      module AbstractorAbstractionSchemaSourceVariant
        def self.included(base)
          base.send :include, SoftDelete
          base.send :belongs_to, :abstractor_abstraction_schema_source
        end
      end
    end
  end
end
