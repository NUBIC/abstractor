module Abstractor
  module Methods
    module Models
      module AbstractorSectionNameVariant
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstractor_section
        end
      end
    end
  end
end