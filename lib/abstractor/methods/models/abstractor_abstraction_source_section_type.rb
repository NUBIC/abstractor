module Abstractor
  module Methods
    module Models
      module AbstractorAbstractionSourceSectionType
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :has_many, :abstractor_abstraction_sources
        end
      end
    end
  end
end