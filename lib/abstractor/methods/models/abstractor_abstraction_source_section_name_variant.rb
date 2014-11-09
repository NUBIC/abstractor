module Abstractor
  module Methods
    module Models
      module AbstractorAbstractionSourceSectionNameVariant
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstractor_abstraction_source
        end
      end
    end
  end
end