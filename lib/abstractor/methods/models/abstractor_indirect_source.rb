module Abstractor
  module Methods
    module Models
      module AbstractorIndirectSource
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstractor_abstraction_source
          base.send :belongs_to, :abstractor_abstraction

          # base.send :attr_accessible, :abstractor_abstraction_id, :abstractor_abstraction, :abstractor_abstraction_source_id, :abstractor_abstraction_source, :source_type, :source_id, :source_method, :reviewed
        end
      end
    end
  end
end