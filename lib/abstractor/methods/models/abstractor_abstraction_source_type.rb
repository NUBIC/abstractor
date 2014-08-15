module Abstractor
  module Methods
    module Models
      module AbstractorAbstractionSourceType
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :has_many, :abstractor_abstraction_sources

          # base.send :attr_accessible, :deleted_at, :name
        end
      end
    end
  end
end